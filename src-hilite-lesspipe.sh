#! /bin/sh

for source in "$@"; do
    case $source in
        *ChangeLog|*changelog)
        source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$source" ;;
        *Makefile|*makefile)
        source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$source" ;;
        *.rake)
          source-highlight --failsafe --infer-lang -f esc --style-file=esc.style --src-lang=rb -i "$source" ;;
        # *.md)
        #   pandoc -s -f markdown -t man "$1" | man;;
        *.tar|*.tgz|*.gz|*.bz2|*.xz)
        lesspipe "$source" ;;
        *) source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i "$source" ;;
    esac
done
