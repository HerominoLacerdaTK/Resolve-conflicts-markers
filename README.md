╔══════════════════════════════════════════════════════════════╗
║             🔥 Android Kernel Conflict Resolver 🔥          ║
║                     resolve-conflitos-v30H                 ║
╚══════════════════════════════════════════════════════════════╝

USO

chmod +x resolve-conflitos-v30H.sh

▶ Resolver automaticamente preferindo o HEAD (Upstream)
    ./resolve-conflitos-v30H.sh --prefer=head

▶ Resolver automaticamente preferindo a BRANCH (Stock)
    ./resolve-conflitos-v30H.sh --prefer=branch

▶ Resolver conflito por conflito (Modo Interativo)
    ./resolve-conflitos-v30H.sh --interactive


──────────────────────────────────────────────────────────────
                 📌 Comportamento no Git Rebase
──────────────────────────────────────────────────────────────

✔ --prefer=branch
    ➜ Mantém a BRANCH atual (Stock Kernel)

✔ --prefer=head
    ➜ Mantém o HEAD (Upstream Kernel)


──────────────────────────────────────────────────────────────
                  📌 Comportamento no Git Merge
──────────────────────────────────────────────────────────────

✔ --prefer=branch
    ➜ Mantém a BRANCH que está sendo mesclada

✔ --prefer=head
    ➜ Mantém o HEAD (Branch atual)


──────────────────────────────────────────────────────────────
                     💡 Exemplos
──────────────────────────────────────────────────────────────

Git Merge
----------
./resolve-conflitos-v30H.sh --prefer=head
./resolve-conflitos-v30H.sh --prefer=branch

Git Rebase
-----------
./resolve-conflitos-v30H.sh --prefer=head
./resolve-conflitos-v30H.sh --prefer=branch
./resolve-conflitos-v30H.sh --interactive

──────────────────────────────────────────────────────────────
        Android Kernel • Git Merge • Git Rebase • Upstream
──────────────────────────────────────────────────────────────
