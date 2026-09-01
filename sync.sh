#!/bin/bash
set -e

# Se placer dans le dossier où se trouve le script
cd "$(dirname "$(readlink -f "$0")")"

mkdir -p assets

# Fonction : sanitize un nom de fichier (espaces -> tirets, retire les caractères problématiques)
sanitize() {
    echo "$1" | sed -E 's/ /-/g; s/[^a-zA-Z0-9._-]//g'
}

echo "🔧 Réparation des liens déjà cassés (espaces non encodés) dans assets/..."
find assets -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r f; do
    old_filename=$(basename "$f")
    new_filename=$(sanitize "$old_filename")
    if [ "$old_filename" != "$new_filename" ]; then
        mv "$f" "assets/$new_filename"
        find . -name "*.md" -exec sed -i "s|${old_filename}|${new_filename}|g" {} +
    fi
done

echo "📁 Déplacement des nouvelles images vers assets/..."
find . -path ./assets -prune -o -path ./.git -prune -o \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print | while read -r f; do
    old_filename=$(basename "$f")
    new_filename=$(sanitize "$old_filename")
    mv "$f" "assets/$new_filename"
    find . -name "*.md" -exec sed -i "s|!\[\]([^)]*${old_filename})|![](/assets/${new_filename})|g" {} +
    find . -name "*.md" -exec sed -i "s|!\[\[${old_filename}\]\]|![](/assets/${new_filename})|g" {} +
done

echo "🔄 Correction syntaxe Obsidian -> GitHub..."
find . -name "*.md" -exec sed -i 's/!\[\[\(.*\)\]\]/![](\1)/g' {} +

echo "📤 Push vers GitHub..."
git add .
git commit -m "Sync $(date '+%Y-%m-%d %H:%M')" || echo "ℹ️ Rien à commit."
git push origin main

echo "✅ Sync terminé !"