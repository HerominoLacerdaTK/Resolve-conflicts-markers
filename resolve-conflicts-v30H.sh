#!/bin/bash

# 💠 BRUTAL RESOLVE-CONFLITOS v30-H (Heurística)
# Resolve conflitos Git com regras automáticas baseadas no tipo de arquivo.

PREFER="branch"
INTERACTIVE=false
LOG_FILE="resolve-conflicts-v30H.log"
BACKUP_DIR=".brutal-backups"

usage() {
  echo "Uso: $0 [--prefer=head|branch] [--interactive]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --prefer=head) PREFER="head"; shift ;;
    --prefer=branch) PREFER="branch"; shift ;;
    --interactive) INTERACTIVE=true; shift ;;
    -h|--help) usage ;;
    *) echo "Argumento desconhecido: $1"; usage ;;
  esac
done

echo "🚀 BRUTAL CONFLIT RESOLVER v30-H — preferindo: $PREFER | interativo: $INTERACTIVE"
mkdir -p "$BACKUP_DIR"
: > "$LOG_FILE"

modified_count=0
skipped_count=0

resolve_conflict() {
  local file="$1"
  cp "$file" "$BACKUP_DIR/$(basename "$file").bak"

  # Heurística por extensão
  case "$file" in
    *.c|*.cpp|*.h) MODE="head" ;;
    *Makefile|*Kbuild|*.mk) MODE="branch" ;;
    *.xml|*.json|*.yml|*.yaml) MODE="merge" ;;
    *) MODE="$PREFER" ;;
  esac

  # Interativo sobrescreve
  if [ "$INTERACTIVE" = true ]; then
    echo "⚠️  Conflito em: $file"
    echo "[1] HEAD | [2] BRANCH | [3] MERGE | [4] Editar nano"
    read -p "Opção: " opt
    case $opt in
      1) MODE="head" ;;
      2) MODE="branch" ;;
      3) MODE="merge" ;;
      4) nano "$file"; git add "$file"; echo "[MANUAL] $file" >> "$LOG_FILE"; return ;;
      *) echo "✘ Opção inválida. Pulando $file"; skipped_count=$((skipped_count+1)); return ;;
    esac
  fi

  # Lógica de resolução
  if [ "$MODE" = "merge" ]; then
    perl -ne '
      BEGIN { $in_conflict=0; $in_head=0; $in_branch=0 }
      if(/^<<<<<<< /){$in_conflict=1;$in_head=1;next}
      if(/^=======/){$in_head=0;$in_branch=1;next}
      if(/^>>>>>>>/){$in_conflict=0;$in_branch=0;next}
      if($in_conflict){
        print if $in_head || $in_branch;   # mantém os dois lados
      } else { print }
    ' "$file" > "$file.tmp"
  else
    perl -ne '
      BEGIN { $mode = $ENV{"MODE"}; $in_conflict=0; $in_head=0; $in_branch=0 }
      if(/^<<<<<<< /){$in_conflict=1;$in_head=1;next}
      if(/^=======/){$in_head=0;$in_branch=1;next}
      if(/^>>>>>>>/){$in_conflict=0;$in_branch=0;next}
      if($in_conflict){
        print if(($mode eq "branch" && $in_branch) || ($mode eq "head" && $in_head));
      } else { print }
    ' "$file" > "$file.tmp"
  fi

  if [ -s "$file.tmp" ]; then
    mv "$file.tmp" "$file"
    git add "$file"
    echo "[RESOLVIDO:$MODE] $file" >> "$LOG_FILE"
    echo "✔ Corrigido ($MODE): $file"
    modified_count=$((modified_count+1))
  else
    echo "⚠️ Sem modificação em $file. Pulando."
    skipped_count=$((skipped_count+1))
    rm -f "$file.tmp"
  fi
}

export -f resolve_conflict
export PREFER INTERACTIVE BACKUP_DIR LOG_FILE

conflict_files=$(grep -rl '^<<<<<<< ' .)

if [ -z "$conflict_files" ]; then
  echo "Nada para resolver: nenhum conflito detectado."
  exit 0
fi

for file in $conflict_files; do
  MODE="$PREFER" resolve_conflict "$file"
done

echo "✅ Conflitos resolvidos: $modified_count"
echo "⏭ Arquivos pulados: $skipped_count"
echo "📋 Log salvo em: $LOG_FILE"
