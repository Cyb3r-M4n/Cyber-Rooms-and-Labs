#!/bin/bash
set -e

# Se placer dans le dossier où se trouve le script (et non un chemin fixe)
cd "$(dirname "$(readlink -f "$0")")"

echo "📁 Déplacement des nouvelles images vers assets/..."
mkdir -p assets
find . -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | grep -v "./assets" | grep -v "./.git" | while read f; do
    filename=$(basename "$f")
    mv "$f" "assets/$filename"
    find . -name "*.md" -exec sed -i "s|!\[\]([^)]*${filename})|![](/assets/${filename})|g" {} +
    find . -name "*.md" -exec sed -i "s|!\[\[${filename}\]\]|![](/assets/${filename})|g" {} +
done

echo "🔄 Correction syntaxe Obsidian -> GitHub..."
find . -name "*.md" -exec sed -i 's/!\[\[\(.*\)\]\]/![](\1)/g' {} +

echo "📤 Push vers GitHub..."
git add .
git commit -m "Sync $(date '+%Y-%m-%d %H:%M')" || echo "ℹ️ Rien à commit."
git push origin main

echo "✅ Sync terminé !"