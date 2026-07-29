#!/bin/bash

# 💠 BRUTAL RESOLVE-CONFLITOS v10
# Resolução automática de conflitos Git com backup, logs, e modo interativo ou preferencial.

PREFER="branch"
INTERACTIVE=false
LOG_FILE="resolve-conflitos-v10.log"
BACKUP_DIR=".brutal-backups"

usage() {
  echo "Uso: $0 [--prefer=head|branch] [--interactive]"
  echo "  --prefer=head     Prefere manter a versão HEAD (padrão é branch)"
  echo "  --prefer=branch   Prefere manter a versão da branch (default)"
  echo "  --interactive     Modo interativo, pergunta para cada arquivo"
  exit 1
}

# Parse argumentos com loop
while [[ $# -gt 0 ]]; do
  case $1 in
    --prefer=head) PREFER="head"; shift ;;
    --prefer=branch) PREFER="branch"; shift ;;
    --interactive) INTERACTIVE=true; shift ;;
    -h|--help) usage ;;
    *) echo "Argumento desconhecido: $1"; usage ;;
  esac
done

echo "🚀 BRUTAL CONFLIT RESOLVER v10 — preferindo: $PREFER | interativo: $INTERACTIVE"
mkdir -p "$BACKUP_DIR"
: > "$LOG_FILE"

modified_count=0
skipped_count=0

resolve_conflict() {
  local file="$1"
  cp "$file" "$BACKUP_DIR/$(basename "$file").bak"

  if [ "$INTERACTIVE" = true ]; then
    echo "⚠️  Conflito detectado em: $file"
    echo "Escolha como resolver:"
    echo "[1] Manter HEAD"
    echo "[2] Manter BRANCH"
    echo "[3] Editar manualmente (nano)"
    read -p "Opção: " opt
    case $opt in
      1) MODE="head" ;;
      2) MODE="branch" ;;
      3) nano "$file"; git add "$file"; echo "[MANUAL] $file" >> "$LOG_FILE"; return ;;
      *) echo "✘ Opção inválida. Pulando $file"; skipped_count=$((skipped_count+1)); return ;;
    esac
  else
    MODE="$PREFER"
  fi

  awk -v mode="$MODE" '
  BEGIN { in_conflict=0; in_head=0; in_branch=0; }
  /^<<<<<<< / { in_conflict=1; in_head=1; next }
  /^=======/   { in_head=0; in_branch=1; next }
  /^>>>>>>>/   { in_conflict=0; in_branch=0; next }
  {
    if (in_conflict) {
      if ((mode == "branch" && in_branch) || (mode == "head" && in_head))
        print;
    } else {
      print;
    }
  }' "$file" > "$file.tmp"

  if [ -s "$file.tmp" ]; then
    mv "$file.tmp" "$file"
    git add "$file"
    echo "[RESOLVIDO:$MODE] $file" >> "$LOG_FILE"
    echo "✔ Corrigido ($MODE): $file"
    modified_count=$((modified_count+1))
  else
    echo "⚠️ Arquivo $file não modificado. Pulando."
    skipped_count=$((skipped_count+1))
    rm -f "$file.tmp"
  fi
}

conflict_files=$(grep -rl '^<<<<<<< ' .)

if [ -z "$conflict_files" ]; then
  echo "Nada para resolver: nenhum conflito detectado."
  exit 0
fi

for file in $conflict_files; do
  resolve_conflict "$file"
done

echo "✅ Conflitos resolvidos: $modified_count"
echo "⏭ Arquivos pulados: $skipped_count"
echo "📋 Log salvo em: $LOG_FILE"
