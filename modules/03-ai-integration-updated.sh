# -------------------- Asistentes CLI nativos + instalación solo --------------------
install_assistants(){
  mark "Preparando shims y entorno para CLIs…"

  # Shim ripgrep → evita "Unknown platform: android"
  RG="$(command -v rg || true)"; [[ -n "$RG" ]] || die "ripgrep no está en PATH."
  cat > "$SHIMS_DIR/rg-shim.js" <<EOF
const Module=require('module');const orig=Module._load;const RG=${RG@Q};
Module._load=function(req,p,i){if(req==='@vscode/ripgrep'||req==='@lvce-editor/ripgrep'){return{rgPath:RG}};return orig.apply(this,arguments)}
EOF

  export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
  export SSL_CERT_DIR="$PREFIX/etc/tls/certs"
  export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
  export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
  export CURL_CA_BUNDLE="$SSL_CERT_FILE"
  export GYP_DEFINES="android_ndk_path=/dev/null"
  export npm_config_build_from_source=true
  export npm_config_python="$(command -v python3)"
  export CC=clang
  export CXX=clang++
  export NODE_OPTIONS="--require $SHIMS_DIR/rg-shim.js ${NODE_OPTIONS:-}"

  mark "Instalando CLIs (idempotente)…"
  is_cmd gemini || npm i -g @google/gemini-cli || true
  is_cmd codex  || npm i -g @openai/codex      || true
  is_cmd qwen   || is_cmd qwen-code || npm i -g @qwen-code/qwen-code || true

  # Wrappers --run (parches siempre activos)
  make_run(){
    local name="$1" entry="$2"
    cat > "$WRAP_DIR/${name}-run" <<EOF
#!/usr/bin/env bash
export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
export SSL_CERT_DIR="$PREFIX/etc/tls/certs"
export REQUESTS_CA_BUNDLE="\$SSL_CERT_FILE"
export NODE_EXTRA_CA_CERTS="\$SSL_CERT_FILE"
export CURL_CA_BUNDLE="\$SSL_CERT_FILE"
export GYP_DEFINES="android_ndk_path=/dev/null"
export npm_config_build_from_source=true
export npm_config_python="\$(command -v python3)"
export CC=clang
export CXX=clang++
export NODE_OPTIONS="--require $SHIMS_DIR/rg-shim.js \${NODE_OPTIONS:-}"
export BROWSER="xdg-open"
exec $entry "\$@"
EOF
    chmod +x "$WRAP_DIR/${name}-run"
  }
  make_run "gemini" "gemini"
  make_run "codex"  "codex"
  make_run "qwen"   "qwen || qwen-code || qwen"

  # PATH actual
  case ":$PATH:" in *:"$WRAP_DIR":*) ;; *) export PATH="$WRAP_DIR:$PATH" ;; esac

  echo "[✓] Asistentes instalados → Usa: gemini-run | codex-run | qwen-run"
}
