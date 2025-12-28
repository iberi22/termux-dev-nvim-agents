#!/usr/bin/env python3
"""
Termux AI Control Panel Backend
FastAPI server with WebSocket support for real-time system monitoring
"""

import asyncio
import os
import subprocess
import json
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import socketio

# Initialize FastAPI app
app = FastAPI(
    title="Termux AI Control Panel API",
    description="Backend API for Termux AI development environment management",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Socket.IO setup
sio = socketio.AsyncServer(cors_allowed_origins="*", async_mode='asgi')
socket_app = socketio.ASGIApp(sio)
app.mount("/socket.io", socket_app)

# Serve static files from web-ui/dist
if Path("../web-ui/dist").exists():
    app.mount("/", StaticFiles(directory="../web-ui/dist", html=True), name="static")

# Data models
class SystemStatus(BaseModel):
    node: bool = False
    git: bool = False
    zsh: bool = False
    neovim: bool = False
    gemini: bool = False
    ssh: bool = False

class GitProject(BaseModel):
    name: str
    path: str
    branch: str
    hasChanges: bool
    lastCommit: Optional[str] = None

class ActionRequest(BaseModel):
    type: str
    params: Optional[Dict] = None

# Global state
connected_clients = set()
system_status = SystemStatus()
disk_usage = {}
git_projects: List[GitProject] = []

# Utility functions
async def run_command(command: str, shell: bool = True) -> tuple[str, str, int]:
    """Run a shell command and return stdout, stderr, and return code"""
    try:
        if isinstance(command, str) and shell:
            process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
        else:
            process = await asyncio.create_subprocess_exec(
                *command.split() if isinstance(command, str) else command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

        stdout, stderr = await process.communicate()
        return stdout.decode().strip(), stderr.decode().strip(), process.returncode
    except Exception as e:
        return "", str(e), 1

async def stream_command(command: str, room: Optional[str] = None, prefix: str = "") -> int:
    """Run a command and stream stdout/stderr lines as task_log events, return exit code"""
    try:
        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        async def reader(stream, level: str):
            while True:
                line = await stream.readline()
                if not line:
                    break
                msg = line.decode(errors="ignore").rstrip()
                if msg:
                    await sio.emit("task_log", {"level": level, "message": f"{prefix}{msg}"}, room=room)

        await asyncio.gather(reader(process.stdout, "info"), reader(process.stderr, "error"))
        return await process.wait()
    except Exception as e:
        await sio.emit("task_log", {"level": "error", "message": f"{prefix}Exception: {e}"}, room=room)
        return 1

def is_termux() -> bool:
    """Check if running in Termux environment"""
    return Path("/data/data/com.termux").exists()

async def check_system_status() -> SystemStatus:
    """Check the status of various system components"""
    status = SystemStatus()

    # Check Node.js
    stdout, _, code = await run_command("node --version")
    status.node = code == 0

    # Check Git
    stdout, _, code = await run_command("git --version")
    status.git = code == 0

    # Check Zsh
    stdout, _, code = await run_command("zsh --version")
    status.zsh = code == 0

    # Check Neovim
    stdout, _, code = await run_command("nvim --version")
    status.neovim = code == 0

    # Check Gemini CLI
    stdout, _, code = await run_command("gemini --version")
    if code == 0:
        # Check if authenticated
        _, _, auth_code = await run_command("gemini auth test")
        status.gemini = auth_code == 0

    # Check SSH server
    stdout, _, code = await run_command("pgrep sshd")
    status.ssh = code == 0

    return status

async def get_disk_usage() -> Dict[str, str]:
    """Get disk usage information"""
    usage = {}
    home = Path.home()

    # Get total home directory size
    stdout, _, code = await run_command(f"du -sh {home}")
    if code == 0:
        usage["Home Total"] = stdout.split()[0]

    # Check specific directories
    important_dirs = {
        ".npm": home / ".npm",
        "termux-ai": home / "termux-ai-setup",
        "src": home / "src",
        ".config": home / ".config"
    }

    for name, path in important_dirs.items():
        if path.exists():
            stdout, _, code = await run_command(f"du -sh {path}")
            if code == 0:
                usage[name] = stdout.split()[0]

    return usage

async def get_git_projects() -> List[GitProject]:
    """Get information about Git projects"""
    projects = []
    src_dir = Path.home() / "src"

    if not src_dir.exists():
        return projects

    for item in src_dir.iterdir():
        if item.is_dir() and (item / ".git").exists():
            try:
                # Get current branch
                stdout, _, code = await run_command(f"git -C {item} branch --show-current")
                branch = stdout if code == 0 else "unknown"

                # Check for changes
                stdout, _, code = await run_command(f"git -C {item} status --porcelain")
                has_changes = code == 0 and bool(stdout.strip())

                # Get last commit
                stdout, _, code = await run_command(f"git -C {item} log -1 --format='%h %s'")
                last_commit = stdout if code == 0 else None

                projects.append(GitProject(
                    name=item.name,
                    path=str(item),
                    branch=branch,
                    hasChanges=has_changes,
                    lastCommit=last_commit
                ))
            except Exception as e:
                print(f"Error processing {item}: {e}")

    return projects

async def broadcast_update(event: str, data: dict):
    """Broadcast update to all connected clients"""
    await sio.emit(event, data)

# Background task to update system status
async def update_system_data():
    """Background task to periodically update system data"""
    global system_status, disk_usage, git_projects

    while True:
        try:
            # Update system status
            new_status = await check_system_status()
            if new_status != system_status:
                system_status = new_status
                await broadcast_update("system_status", system_status.dict())

            # Update disk usage (less frequently)
            new_usage = await get_disk_usage()
            if new_usage != disk_usage:
                disk_usage = new_usage
                await broadcast_update("disk_usage", disk_usage)

            # Update git projects
            new_projects = await get_git_projects()
            if new_projects != git_projects:
                git_projects = new_projects
                await broadcast_update("git_projects", [p.dict() for p in git_projects])

        except Exception as e:
            print(f"Error updating system data: {e}")

        await asyncio.sleep(10)  # Update every 10 seconds

# Socket.IO events
@sio.event
async def connect(sid, environ):
    """Handle client connection"""
    connected_clients.add(sid)
    print(f"Client {sid} connected")

    # Send initial data
    await sio.emit("system_status", system_status.dict(), room=sid)
    await sio.emit("disk_usage", disk_usage, room=sid)
    await sio.emit("git_projects", [p.dict() for p in git_projects], room=sid)

@sio.event
async def disconnect(sid):
    """Handle client disconnection"""
    connected_clients.discard(sid)
    print(f"Client {sid} disconnected")

@sio.event
async def action(sid, data):
    """Handle action requests from clients"""
    try:
        action_type = data.get("type")
        params = data.get("params", {})

        if action_type == "show_ssh_key":
            ssh_key_path = Path.home() / ".ssh" / "id_ed25519.pub"
            if ssh_key_path.exists():
                key_content = ssh_key_path.read_text().strip()
                await sio.emit("ssh_key", {"key": key_content}, room=sid)
            else:
                await sio.emit("log", {
                    "message": "SSH key not found. Generate one with: ssh-keygen -t ed25519",
                    "level": "error"
                }, room=sid)

        elif action_type == "enable_ssh":
            if is_termux():
                stdout, stderr, code = await run_command("sv-enable sshd")
                if code == 0:
                    await sio.emit("log", {
                        "message": "SSH server enabled successfully",
                        "level": "success"
                    }, room=sid)
                else:
                    await sio.emit("log", {
                        "message": f"Failed to enable SSH: {stderr}",
                        "level": "error"
                    }, room=sid)
            else:
                await sio.emit("log", {
                    "message": "SSH server management only available in Termux",
                    "level": "warning"
                }, room=sid)

        elif action_type == "start_http_server":
            await sio.emit("log", {
                "message": "HTTP server functionality integrated in main server",
                "level": "info"
            }, room=sid)

        elif action_type == "gemini_auth_status":
            # Check Gemini CLI auth status
            stdout, stderr, code = await run_command("gemini auth test")
            if code == 0:
                await sio.emit("log", {"message": "Gemini CLI autenticado", "level": "success"}, room=sid)
                await sio.emit("gemini_auth", {"authenticated": True, "details": stdout}, room=sid)
            else:
                await sio.emit("log", {"message": f"Gemini CLI no autenticado: {stderr or stdout}", "level": "warning"}, room=sid)
                await sio.emit("gemini_auth", {"authenticated": False, "details": stderr or stdout}, room=sid)

        elif action_type == "gemini_login":
            # Iniciar el flujo oficial de login con navegador (OAuth)
            await sio.emit("log", {"message": "Iniciando login de Gemini CLI (se abrirá el navegador)...", "level": "info"}, room=sid)

            # Ejecutar login y transmitir la salida en tiempo real
            exit_code = await stream_command("gemini auth login", room=sid, prefix="[gemini] ")

            if exit_code == 0:
                await sio.emit("log", {"message": "Login de Gemini finalizado. Verificando estado...", "level": "success"}, room=sid)
            else:
                await sio.emit("log", {"message": f"El proceso de login terminó con código {exit_code}. Intentando verificar estado...", "level": "warning"}, room=sid)

            # Re-chequear estado tras intentar login
            stdout3, stderr3, code3 = await run_command("gemini auth test")
            await sio.emit("gemini_auth", {"authenticated": code3 == 0, "details": stdout3 or stderr3}, room=sid)

        elif action_type == "run_module":
            # Execute allowed setup modules
            allowed = [
                "00-user-setup","00-base-packages","01-zsh-setup","02-neovim-setup",
                "03-ai-integration","05-ssh-setup","06-fonts-setup","07-local-ssh-server"
            ]
            name = params.get("name") if isinstance(params, dict) else None
            if name not in allowed:
                await sio.emit("log", {"message": f"Módulo no permitido: {name}", "level": "warning"}, room=sid)
            else:
                repo_root = Path(__file__).resolve().parent.parent
                module_path = repo_root / "modules" / f"{name}.sh"
                if not module_path.exists():
                    await sio.emit("log", {"message": f"Módulo no encontrado: {module_path}", "level": "error"}, room=sid)
                else:
                    await sio.emit("task_start", {"task": f"module:{name}"}, room=sid)
                    env = os.environ.copy()
                    env["TERMUX_AI_AUTO"] = "1"
                    # Stream command
                    cmd = f"TERMUX_AI_AUTO=1 bash '{module_path}'"
                    exit_code = await stream_command(cmd, room=sid, prefix=f"[{name}] ")
                    await sio.emit("task_complete", {"task": f"module:{name}", "exitCode": exit_code}, room=sid)

        elif action_type == "test_github_ssh":
            # Test SSH connectivity to GitHub
            cmd = "ssh -o StrictHostKeyChecking=no -T git@github.com"
            exit_code = await stream_command(cmd, room=sid, prefix="[ssh] ")
            level = "success" if exit_code == 1 or exit_code == 0 else "error"
            # Note: Successful unauthenticated test often exits with 1 and message including username
            await sio.emit("log", {"message": f"Prueba SSH finalizada (exit {exit_code})", "level": level}, room=sid)

        elif action_type == "set_repo_remote_ssh":
            # Convert a repo remote origin to SSH
            repo_path = params.get("path") if isinstance(params, dict) else None
            if not repo_path or not Path(repo_path).exists():
                await sio.emit("log", {"message": "Ruta de repo inválida", "level": "error"}, room=sid)
            else:
                # Get current origin URL
                stdout, stderr, code = await run_command(f"git -C '{repo_path}' remote get-url origin")
                if code != 0:
                    await sio.emit("log", {"message": f"No se pudo obtener remote: {stderr}", "level": "error"}, room=sid)
                else:
                    url = stdout.strip()
                    ssh_url = None
                    if url.startswith("git@"):
                        ssh_url = url
                    elif url.startswith("https://github.com/"):
                        path = url.split("https://github.com/")[-1]
                        ssh_url = f"git@github.com:{path}"
                    if not ssh_url:
                        await sio.emit("log", {"message": f"URL no reconocida: {url}", "level": "warning"}, room=sid)
                    else:
                        stdout2, stderr2, code2 = await run_command(f"git -C '{repo_path}' remote set-url origin '{ssh_url}'")
                        if code2 == 0:
                            await sio.emit("log", {"message": f"Remote origin actualizado a SSH: {ssh_url}", "level": "success"}, room=sid)
                        else:
                            await sio.emit("log", {"message": f"Error actualizando remote: {stderr2}", "level": "error"}, room=sid)

        else:
            await sio.emit("log", {
                "message": f"Unknown action: {action_type}",
                "level": "warning"
            }, room=sid)

    except Exception as e:
        await sio.emit("log", {
            "message": f"Error processing action: {str(e)}",
            "level": "error"
        }, room=sid)

# API endpoints
@app.get("/api/status")
async def get_status():
    """Get current system status"""
    return {
        "system": system_status.dict(),
        "disk": disk_usage,
        "projects": [p.dict() for p in git_projects]
    }

@app.post("/api/action")
async def handle_action(action: ActionRequest):
    """Handle action requests via HTTP"""
    # This could be extended to handle actions that don't require WebSocket
    return {"message": "Use WebSocket for real-time actions"}

# Startup event
@app.on_event("startup")
async def startup_event():
    """Initialize the application"""
    global system_status, disk_usage, git_projects

    print("Starting Termux AI Control Panel Backend...")

    # Initial data load
    system_status = await check_system_status()
    disk_usage = await get_disk_usage()
    git_projects = await get_git_projects()

    # Start background task
    asyncio.create_task(update_system_data())

    print("Backend initialized successfully!")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        access_log=True
    )