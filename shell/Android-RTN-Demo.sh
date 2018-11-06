#!/bin/bash

echo  "\033[32m ----------------------------------------------------------------- \033[0m"
echo  "\033[32m                                                                   \033[0m"
echo  "\033[32m       Android自研连麦Demo自动安装、调起、连麦测试                       \033[0m"
echo  "\033[32m       1. 把测试APK命名为app-rtc.apk，并放到根目录下，如/Users/XXX       \033[0m"
echo  "\033[32m       2. 安装&调起                                                 \033[0m"
echo  "\033[32m       3. 输入用户昵称(deviceID)、房间号为默认test                      \033[0m"
echo  "\033[32m       4. 开始连麦                                                   \033[0m"
echo  "\033[32m       5. 退出连麦                                                   \033[0m"
echo  "\033[32m ----------------------------------------------------------------- \033[0m"

#一些基本信息
function initEcho(){
#Android RTN 测试 Demo的包名
PACKAGE_NAME="com.qiniu.droid.rtc.demo"
#Android RTN 测试 Demo的Activity名
MAIN_ACTIVITY_NAME="/.activity.WelcomeActivity"
#APK名字
#把测试demo取名为app-rtc.apk，并把它放到用户根目录下
APK_NAME='app-rtc.apk'
#安装路径
INSTALL_PATH="$(pwd)""/""$APK_NAME"
#连麦时间
TEST_TIME=60
}
initEcho

#主界面Activity
WELCOME_ACTIVITY="com.qiniu.droid.rtc.demo/.activity.WelcomeActivity"
#连麦房间Activity
ROOM_ACTIVITY="com.qiniu.droid.rtc.demo/.activity.RoomActivity"
#OPPO的安装确认界面
OPPO_INSTALL_ACTIVITY="com.android.packageinstaller/.OppoPackageInstallerActivity"


#得到所有连接设备名及设备数量
echo  "\033[32m          得到所有连接设备名及设备数量          \033[0m"
function getDevices(){
devices=`adb devices | grep 'device$' | awk '{print $1}' | tr '\n' ' '` ;
printf "All devices list:%s\n" "${devices[@]}";
devices=(${devices});
printf "Devices numbers:%d\n " ${#devices[@]};
}
getDevices

#抓log,在根目录下创建shell_test_log文件夹用以存放log
function initLog()
{
  clearLog
  echo "initLog被调用"
  mkdir shell_test_log
  cd shell_test_log
  adb -s $DEVICE logcat -v time >"$DEVICE" &
}

#清理之前的log
function clearLog(){
  echo "clearLog被调用"
  rm -rf shell_test_log
  rm -rf Crash_Count.txt
  adb -s $DEVICE logcat -c
}

#安装测试Demo到所有的连接设备
function installDemo()
{
echo  "\033[32m          安装测试Demo到手机          \033[0m"
cd ..
echo "设备编号:"$DEVICE
echo "如果已经安装，则卸载应用"
adb -s $DEVICE shell pm uninstall $PACKAGE_NAME
echo "安装"
adb -s $DEVICE  install -r $INSTALL_PATH
#adb -s $DEVICE shell pm install -r "/data/local/tmp/$APK_NAME"
installButton

#adb -s ${DEVICE_ID} shell pm grant $PACKAGE_NAME "android.permission.READ_EXTERNAL_STORAGE"
#adb -s ${DEVICE_ID} shell pm grant $PACKAGE_NAME  "android.permission.CAMERA"
#adb -s ${DEVICE_ID} shell pm grant $PACKAGE_NAME "android.permission.RECORD_AUDIO"
}
function installButton(){
 case $DEVICE in
       '5SYD6HTCZ9NZY5MJ')
          echo "为OPPO手机专门写的：OPPO安装需要手动确认"
          if [ $CURRENT_ACTIVITY = $OPPO_INSTALL_ACTIVITY ];then
          #点击安装
          echo "在OPPO的安装确认界面"
          adb -s $DEVICE shell input tap 450 1100
          sleep 20
          echo $DEVICE "Confirm app install"
          fi
          ;;
  esac
}

#调起Demo
function startDemo()
{
echo  "\033[32m          调起测试Demo          \033[0m"
echo  "设备编号:"$DEVICE
adb -s $DEVICE shell am start -n "$PACKAGE_NAME""$MAIN_ACTIVITY_NAME"
}

#输入用户昵称（后面直接在Demo上输入），点击保存昵称
function inputNickName(){
echo  "\033[32m          输入用户昵称         \033[0m"
echo  "设备编号:"$DEVICE
sleep 10
adb -s $DEVICE shell input text "$DEVICE"
sleep 20

 case $DEVICE in
   'CLB7N18709004192')
   echo  "\033[32m          P20保存昵称          \033[0m"
   adb -s $DEVICE shell input tap 352 600
   sleep 5
   permissionButton
   ;;

   '74090c2')
   echo  "\033[32m          小米5S保存昵称          \033[0m"
   adb -s $DEVICE shell input tap 530 600
   sleep 5
   permissionButton
   ;;
esac
}

#加入会议房间，开始连麦，房间号默认test
function joinRoom()
{
echo  "\033[32m          加入会议房间         \033[0m"
echo  "设备编号:"$DEVICE
adb -s $DEVICE shell input tap 410 900
echo  "连麦:" $TEST_TIME "s"
sleep $TEST_TIME
}

#获取手机权限
function permissionButton(){
  case $DEVICE in
     'CLB7N18709004192')
      echo "华为P20获取手机权限确认"
      #点击OK
      adb -s $DEVICE shell input tap 888 1300
      sleep 5
      #点击掉 始终允许
      for i in {1..3}
       do
        echo $i
        adb -s $DEVICE shell input tap 800 2100
        sleep 5
       done
       #点击保存昵称
       adb -s $DEVICE shell input tap 352 600
       sleep 5
       ;;

      '74090c2')
      echo "小米5S获取手机权限确认"
      #点击OK
      adb -s $DEVICE shell input tap 900 1100
      sleep 5
      #点击掉 始终允许
      for i in {1..3}
      do
       echo $i
       adb -s $DEVICE shell input tap 800 1800
       sleep 5
      done
      #点击保存昵称
      adb -s $DEVICE shell input tap 530 600
      sleep 5
      ;;

   esac
}

#得到当前的Activity
function getActiveActivity()
{
ACTIVITIES=$(adb -s $DEVICE shell dumpsys activity | grep -i run | grep '#')
ACTIVITY=$(adb -s $DEVICE shell dumpsys activity | grep -i run | grep '#'| head -n 1)
echo $ACTIVITY " " $DEVICE
CURRENT_ACTIVITY=$(adb -s $DEVICE shell dumpsys activity | grep -i run | grep '#'| head -n 1 | awk '{print $5}')
echo  "当前Activity为:" $CURRENT_ACTIVITY
}

#校验是否在连麦界面，判断是否Crash
function checkCrash(){
CRASH_COUNT=0
if [ $CURRENT_ACTIVITY = $ROOM_ACTIVITY ];
then
   echo  "\033[32m          Good:在连麦界面，没有Crash          \033[0m"
   sleep 20
else
   ((CRASH_COUNT+=1))
   echo  "\033[31m          Warning：不在连麦界面，需要看log进行排查          \033[0m"
   echo $CRASH_COUNT >Crash_Count.txt
   sleep 20
fi
}

#退出房间，挂断连麦，返回到手机主页面
function exitRoom()
{
  echo  "\033[32m          退出会议房间         \033[0m"
  echo  "设备编号:"$DEVICE
  adb -s $DEVICE shell input tap 500 2000
  #点击返回键
  adb shell input keyevent 4
}

for DEVICE in ${devices[@]}
do
{
  echo  "\033[32m          当前执行的设备为:$DEVICE          \033[0m"
  initLog
  installDemo
  startDemo
  inputNickName
  joinRoom
  getActiveActivity
  checkCrash
  exitRoom
} &
done
wait

