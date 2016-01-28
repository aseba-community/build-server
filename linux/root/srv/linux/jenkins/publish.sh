#!/bin/sh
set -eu

cd debian
for file in `find -name Packages`
do dir=`dirname "$file"`
dpkg-scanpackages "$dir" > "$file"
done
cd ..

for index in `find -name index.html`
do dir=`dirname "$index"`
	latest="$dir/latest.php"
	rm --force "$latest"
	cat > "$index" <<EOF
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>$dir</title>
	</head>
	<body>
		<ul>
EOF
	for file in `ls --ignore=index.html -t "$dir"`
	do
		if ! [ -f "$latest" ]
		then echo "<? header('Location: $file'); ?>" > $latest
		fi
		date=`stat --format=%y "$dir/$file" | cut --delimiter=. --fields=1`
		cat >> "$index" <<EOF
			<li>
				$date <a href="$file">$file</a>
			</li>
EOF
	done
	cat >> "$index" <<EOF
		</ul>
	</body>
</html>
EOF
done

lftp << EOF
set ssl:verify-certificate false
open mobots.epfl.ch
cd htdocs/data/aseba-build-server
mirror --reverse
EOF
