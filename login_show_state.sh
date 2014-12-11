printf "\tSystem information as of $(date)\n"
printf "\n"
echo -e "\tSystem load: $(uptime | awk -F '[ ,]' '{print $14}')         Processes: $(ps -ef | wc -l)\r"
usage=$(df -h / | awk 'NR==2{print $5 " of " $2 "B"}')
echo -e "\tUsage of /: ${usage}\t User logged in: $(who | wc -l)\r"

Buffers=`grep -we 'Buffers' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
Cached=`grep -we 'Cached' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
MemFree=`grep -ie 'MemFree' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
MemTotal=`grep -ie 'MemTotal' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
SwapCached=`grep -ie 'SwapCached' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
SwapFree=`grep -ie 'SwapFree' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
SwapTotal=`grep -ie 'SwapTotal' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`

MEMUSED="$(( (  $MemTotal - $MemFree  - $Cached  - $Buffers ) *100 / $MemTotal ))"
SWAPUSED="$((( $SwapTotal - $SwapFree ) * 100 / $SwapTotal ))"
echo -e "\tMemory usaage:$MEMUSED%\r"
echo -e "\tSwap usage:$SWAPUSED%\r"

for i in `ifconfig  | awk '$1~/eth[0-9]/{print $1}'`
do
IP=$(ifconfig $i| awk -F'[ :]+' 'NR==2{print $4}')
echo -e "\tIP address for $i:" $IP
done