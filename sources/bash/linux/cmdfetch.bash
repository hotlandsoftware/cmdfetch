#/bin/bash
# cmdfetch by Hotlands Software, Inc. 

# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")

# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi

# If GNU/Hurd
if [ "$UNAME" == "gnu" ]; then
    # Use release info file
	export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
fi

# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && export DISTRO=$UNAME
unset UNAME

# Arch Linux
if [[ "$DISTRO" == *"arch"* ]]; then
user=$(whoami) # Get Username
hostname=$(hostname) # Get Hostname
version=$(cat /etc/issue | head -n1 | cut -c1-11)
kernel=$(uname -r)
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
packages=$(pacman -Qq | wc -l)
shell=$(ls -l /proc/$$/exe | sed 's%.*/%%')
resolution=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/') #TODO: get resolution of text terminals
processor=$(sed -n 's/^model name[ \t]*: *//p' /proc/cpuinfo | uniq)
gpu=$(lspci | grep VGA | cut -d ":" -f3);RAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2)
totalram=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
freeram=$(awk '/MemAvailable/ { print $2 }' /proc/meminfo)
totalram="$((totalram / 1024))"
freeram="$((totalram - freeram / 1024))"

printf "
                 .:\`
               \`+s:\`
              \`/sso:\`           $user@$hostname
             \`/ossso-           OS: $version
             -ooooooo-          Kernel: $kernel
            .-/+oooooo-         Uptime: $uptime
           :++//++ooooo-        Packages: $packages
         \`:++++++++ooooo-       Shell: $shell
        \`:++++ooooooooooo:\`     Resolution: $resolution
       \`/+oossssooosssssss/\`    CPU: $processor
      .+sssssso:.\`.:ossssss+.   GPU: $gpu
     -+sssssso\`     .ossssss+.  RAM: $freeram MB / $totalram MB
    -osssssss:       /ssssooo+.
  \`:sssssssss-       :sssssso/-\`
 \`/ssssso+/:-.       .:/++ossss+-
\`/ss+/-.\`                \`\`.:/oss:
+/-\`                          \`.-+/
"

fi

# Cygwin
if [[ "$DISTRO" == *"cygwin_nt"* ]]; then
user=$(whoami)
hostname=$(hostname)
version=$(systeminfo | sed -n 's/^OS Name:[[:blank:]]*//p') # todo: find a faster way to do this
kernel=$(uname -r)
packages=$(cygcheck -cd | wc -l)
shell=$(ls -l /proc/$$/exe | sed 's%.*/%%')
reswidth=$(wmic path Win32_VideoController get CurrentHorizontalResolution | grep -o '[0-9]'*)
resheight=$(wmic path Win32_VideoController get CurrentVerticalResolution | grep -o '[0-9]'*)
processor=$(sed -n 's/^model name[ \t]*: *//p' /proc/cpuinfo | uniq)
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
gpu=$(wmic path Win32_VideoController get caption | sed -n '2p')
totalram=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
freeram=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
totalram="$((totalram / 1024))"
freeram="$((totalram - freeram / 1024))"

printf "
                     \`\`\`\`..--:::/+o
        \`\`..--. -/++++ooooooooooooo
:///++oooooooo: +oooooooooooooooooo     $user@$hostname
oooooooooooooo: +oooooooooooooooooo     OS: Cygwin on $version
oooooooooooooo: +oooooooooooooooooo     Kernel: $kernel
oooooooooooooo: +oooooooooooooooooo     Uptime: $uptime
oooooooooooooo: +oooooooooooooooooo     Packages: $packages
+oooooooo+oooo: /oooooooooooooooooo     Shell: $shell
----.---------\` ..--.-.----.-.-..--     Resolution: $reswidth"x"$resheight
oooooooooooooo: /oooooooooooooooooo     CPU: $processor
oooooooooooooo: +oooooooooooooooooo     GPU: $gpu
+ooooooooooooo: +oooooooooooooooooo     RAM: $freeram MB / $totalram MB
oooooooooooooo: +oooooooooooooooooo
+ooooooooooooo: +oooooooooooooooooo
:://++oooooooo\ +oooooooooooooooooo
        \`\`..--. -/++++ooooooooooooo
                      \`\`\`\`..--:://+
"
fi

# Debian-based Distros
if [[ "$DISTRO" == *"debian"* ]]; then
user=$(whoami) # Get Username
hostname=$(hostname) # Get Hostname
version=$(cat /etc/issue | head -n1 | cut -c1-18)
kernel=$(uname -r)
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
packages=$(dpkg-query -f '.\n' -W | wc -l)
shell=$(ls -l /proc/$$/exe | sed 's%.*/%%')
resolution=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/') #TODO: get resolution of text terminals
processor=$(sed -n 's/^model name[ \t]*: *//p' /proc/cpuinfo | uniq)
gpu=$(lspci | grep VGA | cut -d ":" -f3);RAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2)
totalram=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
freeram=$(awk '/MemAvailable/ { print $2 }' /proc/meminfo)
freeramalt=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
totalram="$((totalram / 1024))"
freeram="$((totalram - freeram / 1024))"
freeramalt="$((totalram - freeramalt / 1024))"

# 64 Studio
if [[ $kernel == *"2.6.21-1-multimedia-"* ]]; then # This kernel is a custom kernel used only by 64 Studio.
printf "
          \`\`\`\`\`              \`\`\`\`
       \`.:/+so.           \`\`:/oo.
      \`.-+yhs:\`          \`.-/oyy-       $user@$hostname
     \`./shh+.           \`./+ooyy-       OS: 64 Studio ($version)
   \`.-+shy+-\`\`        \`.-ohs+oyy-       Kernel: $kernel
  \`.:+oso+++o+/.     \`./yhso/oyy-       Uptime: $uptime
 --/oyyyssssooss:  \`\`-+hh+-//oyy-       Packages: $packages
.//shh/.\`\`.:o+oyy.\`.:shy:\`\`//oyy-\`      Shell: $shell
:++sho\`     +/oyh/.:oys+::::/oss//.     Resolution: $resolution
.o+oss-\`  \`\`-/shss+sssooooo++osssh/     CPU: $cpu
 -ooooo+//::+yhy::++++++++oo+oyhoo:     RAM: $freeramalt MB / $totalram MB
  \`:+sssssyyys+-\`         \`+syyy-\`
    \`\`-://::.\`\`            \`----\`
.o/+-\`\`/ss/\`\`:: /:\`\`+o+:  .+.\`/+++\`
:y++:\`  oo. \`+o\`oo\`.s/\`h:\`-y:.h-\`y:
\`..oo.  oo\` \`+o\`oo\`.s/\`h/\`.y:.h-\`y/
:y./s-  +o\` \`+s\`oo..s/ h/\`.y:.h-\`y/
 -+o+.  -:\`  \`:+s/\`\`/o++-\`\`/- :+++-
"
exit 1
fi

# Damn Small Linux
if [ -e "/ramdisk/opt/.backgrounds/dsl.jpg" ] # Check for file (todo: check for background on installed copies of DSL)
then
printf "
           \`.-/+ooo+/:.\`
       \`-oyhddhhhddddmmmhs:\`
     .oyhhyhhhhhdddddmmmmmNms-          $user@$hostname
   .ohy+oyhhdmNNNNNmmmmmmNNNNNy.        OS: Damn Small Linux
  -hyyyyhhddmmNd/-\`/mmmmNNNNNMMN/       Kernel: $kernel
 :myyyyhhdN-\`o--:s- .mNNNNNNMMMMM/      Uptime: $uptime
\`mysoyhhhmd\` :+.-:/--dMNNNMMMMMMMN.     Shell: $shell
+myssyhhhdN:.:///+oymMNNNMMMNNMmmNy     Packages: 0
hdyhhhhhhdddhddsodmdmNMMNNMmdmmdmNN     CPU: $(cat /proc/cpuinfo | grep -E 'model name[[:space:]]*:' | cut -c 13-)
hmyhhhhdddddmMm+oyyssohhmNhyhdmNMMN     GPU: $gpu
+NhhhhddddddMNhshhso+y::::+ymNNNNNs     RAM: $freeramalt MB / $totalram MB
\`mmhhdddddmmNNyhddssys+//::+ooooos\`
 -NmdddddmmmmmdMMMddhhs++ymNddhhh-
  -dNmddmmmmmNNmddsodMNMMMMMMMMN/
   .sNNmmmmmNNNNNmNMMMMMMMMMMNy.
     .omNNNNNNNMMMMMMMMMMMMms-
       \`-ohNMMMMMMMMMMMNhs:\`
           \`.-/+osoo/:.\`
"
exit 1
fi

# Vanilla Debian
printf "
             \`-://:--::.\`
        \`-/syyyyyyyyyyyys+o:.\`
     \`./syyyyo+:......-/+syyys/.        $user@$hostname
    .+yyys+..\`           \`-+yyys/\`      OS: $version
   -oys+-\`                 \`:oyyyo      Kernel: $kernel
 \`/ss/.           \`..\`\`      .oyo-\`     Uptime: $uptime
 :yy:          \`:/:--.\`\`      -yy:      Packages: $packages
\`yy/\`         :/.             .oy+      Shell: $shell
.ys.         -+.              .oy+      Resolution: $resolution
.yo.         //.              -ss\`      CPU: $processor
.y+\`         -o-             .+o-       GPU: $gpu
.ys.         \`:+:\`   \`\`    \`-+/\`        RAM: $freeram MB / $totalram MB
 sy-         \`\`\`://-.\`\`.-://:.
 :yo:\`          \`.::://::..\`
  +yy/\`
  \`+yy:
   \`:ss:\`
     .+s+.
       ./s+-
         \`:++:.\`
             .::-.\`
"
fi

# MINGW64
if [[ "$DISTRO" == *"mingw64_nt"* ]]; then
user=$(whoami) # Get Username
hostname=$(hostname) # Get Hostname
version=$(systeminfo | sed -n 's/^OS Name:[[:blank:]]*//p') # todo: find a faster way to do this
kernel=$(uname -r) # Get Kernel Version
packages=$(cygcheck -cd | wc -l)
shell=$(ls -l /proc/$$/exe | sed 's%.*/%%')
reswidth=$(wmic path Win32_VideoController get CurrentHorizontalResolution | grep -o '[0-9]'*)
resheight=$(wmic path Win32_VideoController get CurrentVerticalResolution | grep -o '[0-9]'*)
processor=$(sed -n 's/^model name[ \t]*: *//p' /proc/cpuinfo | uniq)
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
gpu=$(wmic path Win32_VideoController get caption | sed -n '2p')
totalram=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
freeram=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
totalram="$((totalram / 1024))"
freeram="$((totalram - freeram / 1024))"

printf "
                     \`\`\`\`..--:::/+o
        \`\`..--. -/++++ooooooooooooo
:///++oooooooo: +oooooooooooooooooo     $user@$hostname
oooooooooooooo: +oooooooooooooooooo     OS: MINGW64 on $version
oooooooooooooo: +oooooooooooooooooo     Kernel: $kernel
oooooooooooooo: +oooooooooooooooooo     Uptime: $uptime
oooooooooooooo: +oooooooooooooooooo     Packages: $packages
+oooooooo+oooo: /oooooooooooooooooo     Shell: $shell
----.---------\` ..--.-.----.-.-..--     Resolution: $reswidth"x"$resheight
oooooooooooooo: /oooooooooooooooooo     CPU: $processor
oooooooooooooo: +oooooooooooooooooo     GPU: $gpu
+ooooooooooooo: +oooooooooooooooooo     RAM: $freeram MB / $totalram MB
oooooooooooooo: +oooooooooooooooooo
+ooooooooooooo: +oooooooooooooooooo
:://++oooooooo\ +oooooooooooooooooo
        \`\`..--. -/++++ooooooooooooo
                      \`\`\`\`..--:://+
"
fi

# Ubuntu
if [[ "$DISTRO" == *"Ubuntu"* ]]; then
user=$(whoami) # Get Username
hostname=$(hostname) # Get Hostname
version=$(cat /etc/issue | head -n1 | cut -c1-18)
kernel=$(uname -r)
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
packages=$(dpkg-query -f '.\n' -W | wc -l)
shell=$(ls -l /proc/$$/exe | sed 's%.*/%%')
resolution=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/') #TODO: get resolution of text terminals
processor=$(sed -n 's/^model name[ \t]*: *//p' /proc/cpuinfo | uniq)
gpu=$(lspci | grep VGA | cut -d ":" -f3);RAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2)
totalram=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
freeram=$(awk '/MemAvailable/ { print $2 }' /proc/meminfo)
freeramalt=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
totalram="$((totalram / 1024))"
freeram="$((totalram - freeram / 1024))"
freeramalt="$((totalram - freeramalt / 1024))"

# Linux Subsystem for Windows
if [[ $kernel == *"4.4.0-17134-Microsoft"* ]]; then # This kernel is a custom kernel only used by WSL.
printf "
                 \`\`\`\`\`\`    ..\`
           \`-/+oosssso+.:syyy+\`
        \`-:./ssssssssso.ohhhhh-         $user@$hostname
      \`:/++/\`:sssssssss::oyys/..        OS: $version
     -/+++++/\`.:.\`\`\`\`.-/+/::/+ss:       Kernel: $kernel
    -++++++:.           \`-oysssss:      Uptime: $uptime
  \`.:-:/+/-\`              \`/ssssss.     Packages: $packages
\`+ssso-./:                 \`+yyyyy+     Shell: $shell
:ysssy+\`/-                  .::::::     CPU: $processor
\`:ooo/--+:                  :sooooo     RAM: $freeramalt MB / $totalram MB
   .::/++/.                -sssssy:
    /+++++/-             \`:sssssy+\`
    \`:++++++/\`\`\`      \`./ossssss+\`
     \`-/++++-.oso++++oo/:--:/os:\`
       \`-//.-sssssssys.:/++/:.\`
          \`.+ssyysssy+\`/++++/.
             \`\`.--::-- .://:.
"
exit 1
fi

printf "
                 \`\`\`\`\`\`    ..\`
           \`-/+oosssso+.:syyy+\`
        \`-:./ssssssssso.ohhhhh-         $user@$hostname
      \`:/++/\`:sssssssss::oyys/..        OS: $version
     -/+++++/\`.:.\`\`\`\`.-/+/::/+ss:       Kernel: $kernel
    -++++++:.           \`-oysssss:      Uptime: $uptime
  \`.:-:/+/-\`              \`/ssssss.     Packages: $packages
\`+ssso-./:                 \`+yyyyy+     Shell: $shell
:ysssy+\`/-                  .::::::     Resolution: $resolution
\`:ooo/--+:                  :sooooo     CPU: $processor
   .::/++/.                -sssssy:	GPU: $gpu
    /+++++/-             \`:sssssy+\`     RAM: $freeram MB / $totalram MB
    \`:++++++/\`\`\`      \`./ossssss+\`
     \`-/++++-.oso++++oo/:--:/os:\`
       \`-//.-sssssssys.:/++/:.\`
          \`.+ssyysssy+\`/++++/.
             \`\`.--::-- .://:.
"
fi
