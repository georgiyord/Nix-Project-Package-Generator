source $stdenv/setup

LANGUAGE=$(github-linguist $src | sed -n 's/^ *language: *//p')

handle_CSHARP() {
	cat <<EOF >$out
#!/bin/bash
exec dotnet run $src
EOF
    chmod +x $out
	patchShebangs $out
}

handle_C() {
	gcc $src -o $out
}

handle_COBOL() {
	cp $src ./$name.cob
	cobc -x ./$name.cob -o $out
}

handle_CPP() {
	g++ $src -o $out
}

handle_Go() {
	go build -o $out $src
}

handle_Groovy() {
	mkdir -p $out/bin
	mkdir -p $out/share

	cp $src $name.groovy
	groovyc -d $out/share $name.groovy
	cat <<EOF >$out/bin/$name
#!/bin/bash
exec java -cp "\$GROOVY_HOME/lib/*:$out/share" "$name"
EOF
    chmod +x $out/bin/$name
	patchShebangs $out/bin/$name
}

handle_Java() {
	mkdir -p $out/bin
	mkdir -p $out/share

	CLASS_NAME=$(sed -n 's/.*public[[:space:]]\+class[[:space:]]\+\([a-zA-Z0-9_$]\+\).*/\1/p' "$src")

	cp $src $CLASS_NAME.java
	javac -d $out/share $CLASS_NAME.java
	cat <<EOF >$out/bin/$name
#!/bin/bash
exec java -cp $out/share $CLASS_NAME
EOF
    chmod +x $out/bin/$name
	patchShebangs $out/bin/$name
}

handle_JavaScript() {
	cat <<EOF >$out
#!/bin/bash
exec node $src
EOF
    chmod +x $out
	patchShebangs $out
}

handle_Kotlin() {
	mkdir -p $out/bin
	mkdir -p $out/share

	cp $src $name.kt
	kotlinc -d $out/share $name.kt
	cat <<EOF >$out/bin/$name
#!/bin/bash
exec java -cp $out/share "${name}Kt"
EOF
    chmod +x $out/bin/$name
	patchShebangs $out/bin/$name
}

handle_Perl() {
	cat <<EOF >$out
#!/bin/bash
exec perl $src
EOF
    chmod +x $out
	patchShebangs $out
}

handle_PHP() {
	mkdir -p $out/www
	mkdir -p $out/bin
	cp $src $out/www/index.php
	cat <<EOF >$out/bin/$name
#!/bin/bash
exec php -S "localhost:8080" -t $out/www/
EOF
    chmod +x $out/bin/$name
	patchShebangs $out/bin/$name
}

handle_Python() {
	cat <<EOF >$out
#!/bin/bash
exec python $src
EOF
    chmod +x $out
	patchShebangs $out
}

handle_R() {
	cat <<EOF >$out
#!/bin/bash
exec Rscript $src
EOF
    chmod +x $out
	patchShebangs $out
}

handle_Ruby() {
	cat <<EOF >$out
#!/bin/bash
exec ruby $src
EOF
    chmod +x $out
	patchShebangs $out
}

handle_Rust() {
	rustc $src -o $out
}

handle_Scala() {
	mkdir -p $out/bin
	mkdir -p $out/share

	CLASS_NAME=$(sed -n 's/.*object[[:space:]]\+\([a-zA-Z0-9_$]\+\).*/\1/p' "$src")

	# cp $src $name.kt
	# scalac -d $out/share $name.kt
	scalac -d $out/share $src
	cat <<EOF >$out/bin/$name
#!/bin/bash
exec scala -cp $out/share "$CLASS_NAME"
EOF
    chmod +x $out/bin/$name
	patchShebangs $out/bin/$name
}

handle_Shell() {
	cp $src $out
	chmod +x $out
	patchShebangs $out
}

handle_TypeScript() {
	mkdir -p $out/share
	mkdir -p $out/bin
	tsc --outFile $out/share/script.js $src
	cat <<EOF >$out/bin/$name
#!/bin/bash
exec node $out/share/script.js
EOF
    chmod +x $out/bin/$name
	patchShebangs $out/bin/$name
}

handle_invalid() {
	echo "Cannot handle detected language of single file: $LANGUAGE"
	exit 1
}

if [ "$LANGUAGE" = "C#" ]; then
	handle_CSHARP
elif [ "$LANGUAGE" = "C" ]; then
	handle_C
elif [ "$LANGUAGE" = "COBOL" ]; then
	handle_COBOL
elif [ "$LANGUAGE" = "C++" ]; then
	handle_CPP
elif [ "$LANGUAGE" = "Go" ]; then
	handle_Go
elif [ "$LANGUAGE" = "Groovy" ]; then
	handle_Groovy
elif [ "$LANGUAGE" = "Java" ]; then
	handle_Java
elif [ "$LANGUAGE" = "JavaScript" ]; then
	handle_JavaScript
elif [ "$LANGUAGE" = "Kotlin" ]; then
	handle_Kotlin
elif [ "$LANGUAGE" = "Perl" ]; then
	handle_Perl
elif [ "$LANGUAGE" = "PHP" ]; then
	handle_PHP
elif [ "$LANGUAGE" = "Python" ]; then
	handle_Python
elif [ "$LANGUAGE" = "R" ]; then
	handle_R
elif [ "$LANGUAGE" = "Ruby" ]; then
	handle_Ruby
elif [ "$LANGUAGE" = "Rust" ]; then
	handle_Rust
elif [ "$LANGUAGE" = "Scala" ]; then
	handle_Scala
elif [ "$LANGUAGE" = "Shell" ]; then
	handle_Shell
elif [ "$LANGUAGE" = "TypeScript" ]; then
	handle_TypeScript
else
	handle_invalid
fi
