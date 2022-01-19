#mtklog_start
dsx=0
dsy=0
#id x,y
idx=570
idy=1270
#timelapse x,y
tx=74
ty=1120
#video x,y
vx=224
vy=1120
#auto x,y
ax=360
ay=1120
#blur x,y
blx=510
bly=1120
#beauty x,y
bex=650
bey=1120
#capturex, y
capx=350
capy=1320
#backx,y
backx=180
backy=1460
#total test
total=5000

devces=$(adb devices)
#要将$a分割开，先存储旧的分隔符
OLD_IFS="$IFS"
#设置分隔符
IFS=" " 
#如下会自动分隔
arr=($devces)
#恢复原来的分隔符
IFS="$OLD_IFS"
i=0
#遍历数组
for s in ${arr[@]}
do
i=$[$i+1]
if [ $i == 5 ] 
then
dev="$s"
fi
done
##device
# dev=0123456789ABCDEF
echo "start change_id_normal $dev"

adb -s $dev root
adb -s $dev shell rm sdcard/DCIM/Camera/*

#KILL process
adb -s $dev shell pkill com.myos.camera
adb -s $dev shell pkill camerahalserver
adb -s $dev shell pkill cameraserver

#open mtklog
sleep 5
adb -s $dev shell am start com.ape.logger/.ui.LoggerActivity
#mtklog_permission

sleep 1
adb -s $dev shell input tap $dsx $dsy

#wait mtk process start
sleep 2

#LOG file
firstDir=$(pwd)/change_id_normal
if [[ ! -d "$firstDir" ]]; then
	mkdir $firstDir
fi

scondDir=$firstDir/$(date +%Y-%m-%d-%H-%M-%S)

mkdir $scondDir

cameraAppMemroyFile=$scondDir/changeid_cameraApp_memory.txt  #操作app日志存放路径     
cameraServerMemroyFile=$scondDir/changeid_cameraServer_memory.txt  #操作app日志存放路径
cameraHalServerMemroyFile=$scondDir/changeid_camerHalServer_memory.txt  #操作app日志存放路径  


#open camera
adb -s $dev shell am start com.myos.camera/com.myos.camera.activity.CameraActivity

sleep 2
adb -s $dev shell input tap $ax $ay 

 
function dumpAllProcessMemory()
{
 dumpCameraAppMemory
 dumpCameraServerMemory
 dumpCameraHalServerMemory
}

function dumpCameraAppMemory()
{
#camera app meminfo
log=$cameraAppMemroyFile
pid=$(adb -s  $dev shell ps -ef | grep "com.myos.camera" | grep -v grep | awk '{print $2}')
echo "cameraapp pid is $pid"  >> $log
adb -s  $dev shell dumpsys meminfo  $pid >> $log
dumpProcessFd $pid $log
echo "###########################################################"  >> $log
}

function dumpCameraServerMemory()
{
#cameraservice meminfo
log=$cameraServerMemroyFile
pid=$(adb -s  $dev shell ps | grep "S cameraserver" | grep -v grep | awk '{print $2}')
echo "cameraservice pid is $pid"  >> $log
adb -s  $dev shell dumpsys meminfo  $pid >> $log
dumpProcessFd $pid $log
echo "###########################################################"  >> $log
}

function dumpCameraHalServerMemory()
{
#camerahalserver meminfo
log=$cameraHalServerMemroyFile
pid=$(adb -s  $dev shell ps -ef | grep "android.hardware.camera.provider@2.4-service_64" | grep -v grep | awk '{print $2}')
echo "camerahalserver pid is $pid"  >> $log
adb -s  $dev shell dumpsys meminfo  $pid >> $log
dumpProcessFd $pid $log
echo "###########################################################"  >> $log

}

function recordingOperation(){
echo "operation count=$1"  >> $cameraAppMemroyFile
echo "operation count=$1"  >> $cameraServerMemroyFile
echo "operation count=$1"  >> $cameraHalServerMemroyFile
}
function dumpProcessFd(){
fd_count=$(adb -s  $dev shell ls /proc/$1/fd -al | wc -l)
echo "Process Fd totalCount:$fd_count"  >> $2
}

for (( i=0; i<=$total; i++ ))
do
adb -s $dev shell input tap $idx $idy  
recordingOperation $i
sleep 1
val=`expr $i % 50`
if [ $val == 0 ] 
then
dumpAllProcessMemory
fi
done

adb -s $dev pull sdcard/Logs $scondDir
