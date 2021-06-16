#!/bin/bash
#############--Proxmox VE Tools--##########################
#  Author : 龍天ivan
#  Mail: ivanhao1984@qq.com
#  Version: v2.2.5
#  Github: https://github.com/ivanhao/pvetools
########################################################

#js whiptail --title "Success" --msgbox "c" 10 60
if [ `export|grep 'LC_ALL'|wc -l` = 0 ];then
    if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
        echo "export LC_ALL='en_US.UTF-8'" >> /etc/profile
    fi
fi
if [ `grep "alias ll" /etc/profile|wc -l` = 0 ];then
    echo "alias ll='ls -alh'" >> /etc/profile
    echo "alias sn='snapraid'" >> /etc/profile
fi
source /etc/profile
#-----------------functions--start------------------#
example(){
#msgbox
whiptail --title "Success" --msgbox "
" 10 60
#yesno
if (whiptail --title "Yes/No Box" --yesno "
" 10 60);then
    echo ""
fi
#password
PASSWORD=$(whiptail --title "Password Box" --passwordbox "
Enter your password and choose Ok to continue.
                " 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your password is:" $m
fi


#input form
NAME=$(whiptail --title "
Free-form Input Box
" --inputbox "
What is your pet's name?
" 10 60
Peter
3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo ""
else
    echo ""
fi

#processing
    apt -y install mailutils
}

smbp(){
m=$(whiptail --title "Password Box" --passwordbox "
Enter samba user 'admin' password:
請輸入samba用戶admin的密碼：
                " 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    while [ true ]
    do
        if [[ ! `echo $m|grep "^[0-9a-zA-Z.-@]*$"` ]] || [[ $m = '^M' ]];then
            whiptail --title "Warnning" --msgbox "
Wrong format!!!   input again:
密碼格式不對！！！請重新輸入：
            " 10 60
            smbp
        else
            break
        fi
    done
fi
}

#修改debian的鏡像源地址：
chSource(){
clear
if [ $1 ];then
    #x=a
    whiptail --title "Warnning" --msgbox "Not supported!
    不支持該模式。" 10 60
    chSource
fi
sver=`cat /etc/debian_version |awk -F"." '{print $1}'`
case "$sver" in
    10 )
        sver="buster"
        ;;
    9 )
        sver="stretch"
        ;;
    8 )
        sver="jessie"
        ;;
    7 )
        sver="wheezy"
        ;;
    6 )
        sver="squeeze"
        ;;
    * )
        sver=""
esac
if [ ! $sver ];then
    whiptail --title "Warnning" --msgbox "Not supported!
    您的版本不支持！無法繼續。" 10 60
    main
fi
    #"a" "Automation mode." \
    #"a" "無腦模式" \
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config apt source:" 25 60 15 \
    "b" "Change to cn source." \
    "c" "Disable enterprise." \
    "d" "Undo Change." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置apt鏡像源:" 25 60 15 \
    "b" "更換爲國内源" \
    "c" "關閉企業更新源" \
    "d" "還原配置" \
    "q" "返回主菜單" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
a | A )
    if (whiptail --title "Yes/No Box" --yesno "修改爲ustc.edu.cn源，禁用企業訂閱更新源，添加非訂閱更新源(ustc.edu.cn),修改ceph鏡像更新源" 10 60) then
        if [ `grep "ustc.edu.cn" /etc/apt/sources.list|wc -l` = 0 ];then
            #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
            cp /etc/apt/sources.list /etc/apt/sources.list.bak
            cp /etc/apt/sources.list.d/pve-no-sub.list /etc/apt/sources.list.d/pve-no-sub.list.bak
            cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
            cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
            echo "deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
    deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
    deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
    deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
    deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
    deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
    deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
    deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free" > /etc/apt/sources.list
            #修改pve 5.x更新源地址爲非訂閱更新源，不使用企業訂閱更新源。
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
            #关闭pve 5.x企业订阅更新源
            sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
            #修改 ceph鏡像更新源
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            軟件源已更換成功！" 10 60
            apt-get update
            apt-get -y install net-tools
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
軟件源已更換成功！" 10 60
        else
            whiptail --title "Success" --msgbox " Already changed apt source to ustc.edu.cn!
已經更換apt源爲 ustc.edu.cn" 10 60
        fi
        if [ ! $1 ];then
            chSource
        fi
    fi
    ;;
	b | B  )
        if [ $L = "en" ];then
            OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config apt source:" 25 60 15 \
            "a" "aliyun.com" \
            "b" "ustc.edu.cn" \
            "q" "Main menu." \
            3>&1 1>&2 2>&3)
        else
            OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置apt鏡像源:" 25 60 15 \
            "a" "aliyun.com" \
            "b" "ustc.edu.cn" \
            "q" "返回主菜單" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$OPTION" in
                a )
                    ss="aliyun.com"
                    ;;
                b)
                    ss="ustc.edu.cn"
                    ;;
                q )
                    chSource
            esac
            if (whiptail --title "Yes/No Box" --yesno "修改更新源爲$ss?" 10 60) then
                if [ `grep $ss /etc/apt/sources.list|wc -l` = 0 ];then
                    cp /etc/apt/sources.list /etc/apt/sources.list.bak
                    #cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
                    #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
                    echo "deb https://mirrors.$ss/debian/ $sver main contrib non-free
        deb-src https://mirrors.$ss/debian/ $sver main contrib non-free
        deb https://mirrors.$ss/debian/ $sver-updates main contrib non-free
        deb-src https://mirrors.$ss/debian/ $sver-updates main contrib non-free
        deb https://mirrors.$ss/debian/ $sver-backports main contrib non-free
        deb-src https://mirrors.$ss/debian/ $sver-backports main contrib non-free
        deb https://mirrors.$ss/debian-security/ $sver/updates main contrib non-free
        deb-src https://mirrors.$ss/debian-security/ $sver/updates main contrib non-free" > /etc/apt/sources.list
                    #修改 ceph鏡像更新源
                    #echo "deb http://mirrors.$ss/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list
                    #修改pve 更新源地址爲非訂閱更新源，不使用企業訂閱更新源。
                    echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
                    whiptail --title "Success" --msgbox " apt source has been changed successfully!
                    軟件源已更換成功！" 10 60
                    apt-get update
                    apt-get -y install net-tools
                    whiptail --title "Success" --msgbox " apt source has been changed successfully!
                    軟件源已更換成功！" 10 60
                else
                    whiptail --title "Success" --msgbox " Already changed apt source to $ss!
已經更換apt源爲 $ss" 10 60
                fi
            else
                chSource
            fi
            chSource
        else
            chSource
        fi
        ;;
    c | C  )
    if (whiptail --title "Yes/No Box" --yesno "禁用企業訂閱更新源?" 10 60) then
        #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
        if [ -f /etc/apt/sources.list.d/pve-no-sub.list ];then
            #修改pve 5.x更新源地址爲非訂閱更新源，不使用企業訂閱更新源
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
        else
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            軟件源已更換成功！" 10 60
        fi
        if [ `grep "^deb" /etc/apt/sources.list.d/pve-enterprise.list|wc -l` != 0 ];then
            #關閉pve 5.x企業訂閱更新源
            sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            軟件源已更換成功！" 10 60
        else
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            軟件源已更換成功！" 10 60
        fi
        chSource
    fi
    ;;
d | D )
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    cp /etc/apt/sources.list.d/pve-no-sub.list.bak /etc/apt/sources.list.d/pve-no-sub.list
    cp /etc/apt/sources.list.d/pve-enterprise.list.bak /etc/apt/sources.list.d/pve-enterprise.list
    #cp /etc/apt/sources.list.d/ceph.list.bak /etc/apt/sources.list.d/ceph.list
    whiptail --title "Success" --msgbox "apt source has been changed successfully!
    軟件源已更換成功！" 10 60
    chSource
    ;;
q )
    echo "q"
    #main
    ;;
esac
fi
}

chMail(){
#set mailutils to send mail
addMail(){
if (whiptail --title "Yes/No Box" --yesno "
Will you want to config mailutils & postfix to send notification?(Y/N):
是否配置mailutils和postfix來發送郵件通知？
" 10 60);then
    qqmail=$(whiptail --title "Config mail" --inputbox "
Input email adress:
输入邮箱地址：
    " 10 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ `echo $qqmail|grep '^[a-zA-Z0-9\_\-\.]*\@[A-Za-z0-9\_\-\.]*\.[a-zA-Z\_\-\.]*$'` ];then
                    break
            else
                whiptail --title "Warnning" --msgbox "
Wrong email format!!!   input xxxx@qq.com for example.retry:
錯誤的郵箱格式！！！請輸入類似xxxx@qq.com并重試：
                " 10 60
                addMail
            fi
        done
        if [[ ! -f /etc/mailname || `dpkg -l|grep mailutils|wc -l` = 0 ]];then
            apt -y install mailutils
        fi
        {
            echo 10
            sleep 1
            $(echo "pve.local" > /etc/mailname)
            echo 40
            sleep 1
            $(sed -i -e "/root:/d" /etc/aliases)
            echo 70
            sleep 1
            $(echo "root: $qqmail">>/etc/aliases)
            echo 100
            sleep 1
        } | whiptail --gauge "Please wait while installing" 10 60 0
        sleep 1
        dpkg-reconfigure postfix
        service postfix reload
        echo "This is a mail test." |mail -s "mail test" root
        whiptail --title "Success" --msgbox "
Config complete and send test email to you.
已經配置好并發送了測試郵件。
        " 10 60
        main
    else
        main
    fi
else
    main
fi
}
if [ -f /etc/mailname ];then
    if (whiptail --title "Yes/No Box" --yesno "
It seems you have already configed it before.Reconfig?
您好像已經配置過這個了。重新配置？
    " --defaultno 10 60);then
        addMail
    else
        main
    fi
fi
addMail
}

chZfs(){
#set max zfs ram
setMen(){
    x=$(whiptail --title "Config ZFS" --inputbox "
set max zfs ram 4(G) or 8(G) etc, just enter number or n?
設置最大zfs内存（zfs_arc_max),比如4(G)或8(G)等, 隻需要輸入純數字即可，比如4G輸入4?
    " 20 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ "$x" =~ ^[1-9]+$ ]]; then
                    update-initramfs -u
                {
                    $(echo "options zfs zfs_arc_max=$[$x*1024*1024*1024]">/etc/modprobe.d/zfs.conf)
                    echo 10
                    echo 70
                    sleep 1
                    #set rpool to list snapshots
                    $(if [ `zpool get listsnapshots|grep rpool|awk '{print $3}'` = "off" ];then
                        zpool set listsnapshots=on rpool
                    fi)
                    echo 100
                }|whiptail --gauge "installing" 10 60 0
                whiptail --title "Success" --msgbox "
Config complete!you should reboot later.
配置完成，一會兒最好重啓一下系統。
                " 10 60
                break
            else
                whiptail --title "Warnning" --msgbox "
Invalidate value.Please comfirm!
輸入的值無效，請重新輸入!
                " 10 60
                setMen
            fi
        done
        #zfs-zed
        if (whiptail --title "Yes/No Box" --yesno "
    Install zfs-zed to get email notification of zfs scrub?(Y/n):
    安裝zfs-zed來發送zfs scrub的結果提醒郵件？(Y/n):
        " 10 60);then
            if [ `dpkg -l|grep zfs-zed|wc -l` = 0 ];then
                apt-get -y install zfs-zed
            fi
            whiptail --title "Success" --msgbox "
    Install complete!
    安裝zfs-zed成功！
            " 10 60
        else
            chZfs
        fi
    else
        main
    fi
}
if [ ! -f /etc/modprobe.d/zfs.conf ] || [ `grep "zfs_arc_max" /etc/modprobe.d/zfs.conf|wc -l` = 0 ];then
    setMen
else
    if(whiptail --title "Yes/No box" --yesno "
It seems you have already configed it before.Reconfig?
您好像已經配置過這個了。是否重新配置？
    " --defaultno 10 60 );then
        setMen
    else
        main
    fi
fi
}

chSamba(){
#config samba
        addSmbRecycle(){
            if(whiptail --title "Yes/No" --yesno "enable recycle?
開啓回收站？" 10 60 )then
                if [ ! -f '/etc/samba/smb.conf' ];then
                    whiptail --title "Warnning" --msgbox "You should install samba first!
    請先安裝samba！" 10 60
                else
                    if [ `sed -n "/\[$2\]/,/$2 end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` != 0 ];then
                        whiptail --title "Warnning" --msgbox "Already configed!  已經配置過了。" 10 60
                        smbRecycle
                    else
                        cat << EOF > ./recycle
# $2--recycle-start--
vfs object = recycle
recycle:repository = $1/.deleted
recycle:keeptree = Yes
recycle:versions = Yes
recycle:maxsixe = 0
recycle:exclude = *.tmp
# $2--recycle-end--
EOF
                        #n=`sed '/\['$2'\]/' /etc/samba/smb.conf -n|sed -n '$p'`
                        cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
                        sed -i '/\['$2'\]/r ./recycle' /etc/samba/smb.conf
                        rm ./recycle
#                        cat << EOF >> /etc/samba/smb.conf
#[$2-recycle]
#comment = All
#browseable = yes
#path = $1/.deleted
#guest ok = no
#read only = no
#create mask = 0750
#directory mask = 0750
#;  $2-recycle end
#EOF
                        systemctl restart smbd
                        whiptail --title "Success" --msgbox "Done.
    配置完成" 10 60
                    fi
                fi
            else
                continue
            fi
        }
        delSmbRecycle(){
            if [ ! -f '/etc/samba/smb.conf' ];then
                whiptail --title "Warnning" --msgbox "You should install samba first!
請先安裝samba！" 10 60
            else
                if [ `sed -n "/\[$1\]/,/$1 end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "Already configed!  已經配置過了。" 10 60
                    smbRecycle
                else
                    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
                    sed -i '/.*'$1'.*recycle.*start/,/.*'$1'.*end/d' /etc/samba/smb.conf
                    sed "/\[${1}\-recycle\]/,/${n}\-recycle end/d" /etc/samba/smb.conf -i
                    systemctl restart smbd
                    whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                fi
            fi
        }

clear
#$(grep -E "^\[[0-9a-zA-Z.-]*\]$|^path" /etc/samba/smb.conf|awk 'NR>3{print $0}'|sed 's/path/        path/'|grep -v '-recycle')
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config samba:" 25 60 15 \
    "a" "Install samba and config user." \
    "b" "Add folder to share." \
    "c" "Delete folder to share." \
    "d" "Config recycle" \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置samba:" 25 60 15 \
    "a" "安裝配置samba并配置好samba用戶" \
    "b" "添加共享文件夾" \
    "c" "取消共享文件夾" \
    "d" "配置回收站" \
    "q" "返回主菜單" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ `grep samba /etc/group|wc -l` = 0 ];then
            if (whiptail --title "Yes/No Box" --yesno "set samba and admin user for samba?
安裝samba并配置admin爲samba用戶？
                " 10 60);then
                apt -y install samba
                groupadd samba
                useradd -g samba -M -s /sbin/nologin admin
                smbp
                echo -e "$m\n$m"|smbpasswd -a admin
                service smbd restart
                echo -e "已成功配置好samba，請記好samba用戶admin的密碼！"
                whiptail --title "Success" --msgbox "
已成功配置好samba，請記好samba用戶admin的密碼！
                " 10 60
            fi
        else
            whiptail --title "Success" --msgbox "Already configed samba.
已配置過samba，沒什麽可做的!
            " 10 60
                    fi
        if [ ! $1 ];then
            chSamba
        fi
        ;;
    b | B )
       # echo -e "Exist share folders:"
       # echo -e "已有的共享目錄："
       # echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
       # echo -e "Input share folder path:"
       # echo -e "輸入共享文件夾的路徑:"
       addFolder(){
        h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
        if [ $h -lt 3 ];then
            let h=$h*15
        else
            let h=$h*5
        fi
        x=$(whiptail --title "Add Samba Share folder" --inputbox "
Exist share folders:
已有的共享目錄：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder path(like /root):
輸入共享文件夾的路徑(隻需要輸入/root類似的路徑):
" $h 60 "" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ ! -d $x ]
            do
                whiptail --title "Success" --msgbox "Path not exist!
路徑不存在！
                " 10 60
                addFolder
            done
            while [ `grep "path \= ${x}$" /etc/samba/smb.conf|wc -l` != 0 ]
            do
                whiptail --title "Success" --msgbox "Path exist!
路徑已存在！
                " 10 60
                addFolder
            done
            n=`echo $x|grep -o "[a-zA-Z0-9.-]*$"`
            while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
            do
                n=$(whiptail --title "Samba Share folder" --inputbox "
Input share name:
輸入共享名稱：
    " 10 60 "" 3>&1 1>&2 2>&3)
                exitstatus=$?
                if [ $exitstatus = 0 ]; then
                    while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
                    do
                        whiptail --title "Success" --msgbox "Name exist!
名称已存在！
                        " 10 60
                        addFolder
                    done
                fi
            done
            oldgrp=`ls -l $x|awk 'NR==2{print $4}'`
            if [ `grep "${x}$" /etc/samba/smb.conf|wc -l` = 0 ];then
                cat << EOF >> /etc/samba/smb.conf
[$n]
comment = All
browseable = yes
path = $x
guest ok = no
read only = no
create mask = 0750
directory mask = 0750
; oldgrp $oldgrp
;  $n end
EOF
                whiptail --title "Success" --msgbox "
Configed!
配置成功！
                " 10 60
                #--2.2.5 add group
                chgrp -R samba $x
                chmod -R g+w $x
                addSmbRecycle $x $n
                service smbd restart
            else
                whiptail --title "Success" --msgbox "Already configed！
已經配置過了！
                " 10 60
            fi
            addFolder
        else
            chSamba
        fi
}
        addFolder
        ;;
    c )
        delFolder(){
        h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
        if [ $h -lt 3 ];then
            let h=$h*15
        else
            let h=$h*5
        fi
        n=$(whiptail --title "Remove Samba Share folder" --inputbox "
Exist share folders:
已有的共享目錄：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
輸入共享文件夾的名稱(隻需要輸入[]中的名字):
        " $h 60 "" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
            do
                whiptail --title "Success" --msgbox "
Name not exist!:
名稱不存在！:
                " 10 60
                delFolder
            done
            if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                oldgrp=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf |grep oldgrp|awk '{print $3}'`
                x=`grep -E "^path = [0-9a-zA-Z/-.]*${n}" /etc/samba/smb.conf|awk '{print $3}'`
                if [ $oldgrp ];then
                    chgrp -R $oldgrp $x
                fi
                sed "/\[${n}\]/,/${n} end/d" /etc/samba/smb.conf -i
                sed "/\[${n}-recycle\]/,/${n}-recycle end/d" /etc/samba/smb.conf -i
                whiptail --title "Success" --msgbox "
Configed!
配置成功！
                " 10 60
                service smbd restart
            fi
            delFolder
        else
            chSamba
        fi
    }
        delFolder
        ;;
    d )
        smbRecycle(){
            if [ $L = "en" ];then
                x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config samba recycle:" 12 60 4 \
                "a" "Enable samba recycle." \
                "b" "Disable samba recycle." \
                "c" "Clear recycle." \
                3>&1 1>&2 2>&3)
            else
                x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置samba回收站！" 12 60 4 \
                "a" "開啓samba回收站。" \
                "b" "關閉samba回收站。" \
                "c" "清空samba回收站。" \
                3>&1 1>&2 2>&3)
            fi
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                case "$x" in
                    a )
                        enSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Remove Samba recycle" --inputbox "
Exist share folders:
已有的共享目錄：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
輸入共享文件夾的名稱(隻需要輸入[]中的名字):
                            " $h 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
                                do
                                    whiptail --title "Success" --msgbox "
Name not exist!:
名稱不存在！:
                                    " 10 60
                                    enSmbRecycle
                                done
                                if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                                    if [ `sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` != 0 ];then
                                        whiptail --title "Warnning" --msgbox "Already configed!  已經配置過了。" 10 60
                                        smbRecycle
                                    else
                                        x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                        addSmbRecycle $x $n
                                        service smbd restart
                                    fi
                                fi
                                disSmbRecycle
                            else
                                smbRecycle
                            fi
                        }
                        enSmbRecycle
                        ;;
                    b )
                        disSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Remove Samba recycle" --inputbox "
Exist share folders:
已有的共享目錄：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
輸入共享文件夾的名稱(隻需要輸入[]中的名字):
                            " $h 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
                                do
                                    whiptail --title "Success" --msgbox "
Name not exist!:
名稱不存在！:
                                    " 10 60
                                    disSmbRecycle
                                done
                                x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                if [ `ls $x/.deleted/|wc -l` != 0 ];then
                                    if(whiptail --title "Warnning" --yesno "recycle not empty, you should clear it first.continue?
回收站中存在文件，建議先清空，是否确認要繼續？" 10 60);then
                                        if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                                            delSmbRecycle $n
                                            service smbd restart
                                        fi
                                        disSmbRecycle
                                    else
                                        disSmbRecycle
                                    fi
                                fi
                            else
                                smbRecycle
                            fi
                        }
                        disSmbRecycle
                        ;;
                    c )
                        checkClearSmb(){
                            c=$(whiptail --title "Clear Samba recycle" --inputbox "
you can disable recycle to clear it.
clear recycle may cause data lose,pvetools will not response for that,do you agree?
type 'YesIdo' to continue:
你可以先取消回收站再手工清空。
工具清空samba回收站不可逆，pvetools不會對此操作負責，是否同意？
如果确認要清空，請輸入'YesIdo'繼續：" 20 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ $c != 'YesIdo' ]
                                do
                                    whiptail --title "Success" --msgbox "
Woring words,try again:
輸入錯誤，請重試:
                                    " 10 60
                                    checkClearSmb
                                done
                            else
                                continue
                            fi
                        }
                        clearSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Clear Samba recycle" --inputbox "
Exist share folders:
已有的共享目錄：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
----------------------------------------
Input share folder name(type words in []):
輸入共享文件夾的名稱(隻需要輸入[]中的名字):
                            " $h 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
                                do
                                    whiptail --title "Success" --msgbox "
Name not exist!:
名稱不存在！:
                                    " 10 60
                                    clearSmbRecycle
                                done
                                x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                if [ `ls -a $x/.deleted/|wc -l` -gt 2 ];then
                                    if(whiptail --title "Warnning" --yesno "recycle not empty,continue?
回收站中存在文件，是否确認要繼續？" 10 60);then
                                        checkClearSmb
                                        rm -rf $x/.deleted/*
                                        rm -rf $x/.deleted/.*
                                        whiptail --title "Success" --msgbox "ok." 10 60
                                    else
                                        clearSmbRecycle
                                    fi
                                else
                                    whiptail --title "Success" --msgbox "Already empty.回收站是空的，不需要清空。" 10 60
                                fi
                            else
                                smbRecycle
                            fi
                        }
                        clearSmbRecycle
                        ;;
                esac
            else
                chSamba
            fi
        }
        smbRecycle
        ;;

    q )
        main
        ;;
    esac
else
    chSamba
fi
}

chVim(){
#config vim
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config VIM:" 12 60 4 \
    "a" "Install vim & simply config display." \
    "b" "Install vim & config 'vim-for-server'." \
    "c" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "安裝配置VIM！" 12 60 4 \
    "a" "安裝VIM并簡單配置，如配色行号等。" \
    "b" "安裝VIM并配置'vim-for-server'。" \
    "c" "還原配置。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
        a )
        if(whiptail --title "Yes/No Box" --yesno "
Install vim & simply config display.Continue?
安裝VIM并簡單配置，如配色行号等，基本是vim原味兒。是否繼續？
            " 10 60) then
            if [ ! -f /root/.vimrc ] || [ `cat /root/.vimrc|wc -l` = 0 ] || [ `dpkg -l |grep vim|wc -l` = 0 ];then
                apt -y install vim
            else
                cp ~/.vimrc ~/.vimrc.bak
            fi
            {
            echo 10
            echo 50
            $(
            cat << EOF > ~/.vimrc
set number
set showcmd
set incsearch
set expandtab
set showcmd
set history=400
set autoread
set ffs=unix,mac,dos
set hlsearch
set shiftwidth=2
set wrap
set ai
set si
set cindent
set termencoding=unix
set tabstop=2
set nocompatible
set showmatch
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set fileformats=unix
set ttyfast
syntax on
set imcmdline
set previewwindow
set showfulltag
set cursorline
set ruler
color ron
autocmd InsertEnter * se cul
set ruler
set showcmd
set laststatus=2
set tabstop=2
set softtabstop=4
inoremap fff <esc>h
autocmd BufWritePost \$MYVIMRC source \$MYVIMRCi
EOF
            )
            echo 100
            }|whiptail --gauge "installing" 10 60
            whiptail --title "Success" --msgbox "
    Install & config complete!
    安裝配置完成!
            " 10 60
        else
            chVim
        fi
            ;;
        b | B )
        if(whiptail --title "Yes/No Box" --yesno "
安裝VIM并配置 \'vim-for-server\'(https://github.com/wklken/vim-for-server).
yes or no?
            " 12 60) then
            echo "Use curl or git? If one not work,change to another."
            echo "選擇git或curl，如果一個方式不行可以換一個。"
            echo "1 ) git"
            echo "2 ) curl"
            echo "Please choose:"
            read x
            case $x in
                2 )
                    apt -y install curl vim
                    cp ~/.vimrc ~/.vimrc_bak
                    curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc
                    whiptail --title "Success" --msgbox "
            Install & config complete!
            安装配置完成！
                    " 10 60
                    ;;
                1 | "" )
                    apt -y install git vim
                    rm -rf vim-for-server
                    git clone https://github.com/wklken/vim-for-server.git
                    mv ~/.vimrc ~/.vimrc_bak
                    mv vim-for-server/vimrc ~/.vimrc
                    rm -rf vim-for-server
                    whiptail --title "Success" --msgbox "
            Install & config complete!
            安裝配置完成！
                    " 10 60
                    ;;
                * )
                    chVim
            esac

        else
            chVim
        fi
            ;;
        c )
            if(whiptail --title "Yes/No Box" --yesno "
Remove Config?
确认要还原配置？
                " --defaultno 10 60) then
                cp ~/.vimrc.bak ~/.vimrc
                whiptail --title "Success" --msgbox "
Done
已經完成配置
                " 10 60
            else
                chVim
            fi
    esac
else
    main
fi
}

chSpindown(){
#set hard drivers to spindown
spinTime(){
    x=$(whiptail --title "config" --inputbox "
input number of minite to auto spindown:
輸入硬盤自動休眠的檢測時間，周期爲分鍾，輸入5爲5分鍾:
    " 10 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ];then
                whiptail --title "Warnning" --msgbox "
輸入格式錯誤，請重新輸入：
                " 10 60
                spinTime
            else
                break
            fi
        done
        cat << eof >> /etc/crontab
*/$x * * * * root /root/hdspindown/spindownall
eof
        service cron reload
        whiptail --title "Success" --msgbox "
config every $x minite to check disks and auto spindown:
已爲您配置好硬盤每$x分鍾自動檢測硬盤和休眠。
        " 10 60
    fi
}
doSpindown(){
    if(whiptail --title "Yes/No Box" --yesno "
    Config hard drives to auto spindown?(Y/n):
    配置硬盤自動休眠？(Y/n):
    " 10 60) then
        if [ `dpkg -l|grep git|wc -l` = 0 ];then
            apt -y install git
        fi
        cd /root
        git clone https://github.com/ivanhao/hdspindown.git
    {
        echo 10
        echo 50
        echo 90
        cd hdspindown
        chmod +x *.sh
        ./spindownall
        echo 100
    }   | whiptail --gauge "installing" 10 60 0
        if [ `grep "spindownall" /etc/crontab|wc -l` = 0 ];then
            spinTime
        fi
    else
        chSpindown
    fi
}
chApm(){
    clear
    apm=$(
    whiptail --title " PveTools   Version : 2.2.5 " --menu "Config hard disks APM & AAM:
配置硬盤靜音、降溫：
    " 25 60 15 \
    "128" "Config hard drivers to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    "d" "Config drivers aam\apm to low temp and quiet." \
    3>&1 1>&2 2>&3)
}

if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config hard disks spindown:" 25 60 15 \
    "a" "Config hard drivers to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    "d" "Config drivers aam\apm to low temp and quiet." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置硬盤自動休眠" 25 60 15 \
    "a" "配置硬盤自動休眠" \
    "b" "還原硬盤自動休眠配置" \
    "c" "配置pvestatd服務（防止休眠後馬上被喚醒）。" \
    "d" "設置硬盤靜音、降溫" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ ! -f /root/hdspindown/spindownall ];then
            doSpindown
        else
            whiptail --title "Yes/No Box" --msgbox "
It seems you have already configed it before.
您好像已經配置過這個了。
                " 10 60
            chSpindown
        fi
        ;;
    b )
        if(whiptail --title "Yes/No Box" --yesno "
Remove config spindown?
确認要還原配置？
        " 10 60) then
            sed -i '/spindownall/d' /etc/crontab
            rm /usr/bin/hdspindown
            if(whiptail --title "Yes/No Box" --yesno "
Remove source code?
是否要删除休眠程序代碼？
            " 10 60) then
                rm -rf /root/hdspindown
            fi
            whiptail --title "Success" --msgbox "
OK
已經完成配置
            " 10 60
        else
            chSpindown
        fi
        ;;
    c )
        if (whiptail --title "Enable/Disable pvestatd" --yes-button "停止(Disable)" --no-button "啓動(Enable)"  --yesno "
pvestatd may spinup the drivers,if hdspindown can not effective, you can disable it to make drives to spindown.
使用lvm的時候pvestatd 可能會造成硬盤頻繁喚醒從而導緻hdspindown無法讓你的硬盤休眠，如果需要，你可以在這裏停止這個服務。
停止這個服務，在web界面将會顯示一些異常，如果需要在web界面進行操作，可以再啓動這個服務。這個操作不是必須的，要自己靈活應用。
        " 20 60) then
        {
            pvestatd stop
            echo 100
            sleep 1
        }|whiptail --gauge "configing..." 10 60 50
        else
        {
            pvestatd start
            echo 100
            sleep 1
        }|whiptail --gauge "configing..." 10 60 50
        fi
        ;;
    esac
fi
}

chCpu(){
maxCpu(){
    info=`cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'`
    x=$(whiptail --title "Max cpufrequtils最大頻率" --inputbox "
$info
--------------------------------------------
Input MAX_SPEED(example: 1.6GHz type 1600000):
輸入最大頻率（示例：1.6GHz 輸入1600000）：
    " 20 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
                whiptail --title "Warnning" --msgbox "
example: 1.6GHz type 1600000
retry
示例：1.6GHz 輸入1600000
輸入格式錯誤,請重新輸入：
                " 15 60
                maxCpu
            else
                break
            fi
        done
        mx=$x
    else
        chCpu
    fi
}
minCpu(){
    x=$(whiptail --title "Mini cpufrequtils最小頻率" --inputbox "
$info
--------------------------------------------
Input MIN_SPEED(example: 1.6GHz type 1600000):
輸入最小頻率（示例：1.6GHz 輸入1600000）：
    " 20 60   3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
                whiptail --title "Warnning" --msgbox "
example: 1.6GHz type 1600000
retry
示例：1.6GHz 輸入1600000
輸入格式錯誤,請重新輸入：
                " 15 60
                minCpu
            else
                break
            fi
        done
        mi=$x
    else
        chCpu
    fi
}

#setup for cpufreq
doChCpu(){
if(whiptail --title "Yes/No Box" --yesno "
Install cpufrequtils to save power?
安裝配置CPU省電?
" --defaultno 10 60) then
    apt -y install cpufrequtils
    if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet intel_pstate=disable|' /etc/default/grub
        update-grub
    fi
    cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'
    maxCpu
    minCpu
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="powersave"
MAX_SPEED="$mx"
MIN_SPEED="$mi"
EOF
    whiptail --title "Success" --msgbox "
cpufrequtils need to reboot to apply! Please reboot.
cpufrequtils 安裝好後需要重啓系統，請稍後重啓。
    " 10 60
else
    main
fi
}
#-------------chCpu--main---------------
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Config cpufrequtils to save power." \
    "b" "Remove config." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "安裝配置CPU省電" 25 60 15 \
    "a" "安裝配置CPU省電" \
    "b" "還原配置" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
            doChCpu
        else
            if(whiptail --title "Yes/No Box" --yesno "
        It seems you have already configed it before.
        您好像已經配置過這個了。
            " --defaultno 10 60) then
                doChCpu
            else
                main
            fi
        fi
        ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
continue?
還原配置？
        " --defaultno 10 60 ) then
            #sed -i 's/ intel_pstate=disable//g' /etc/default/grub
            #rm -rf /etc/default/cpufrequtils
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="ondemand"
EOF
            systemctl restart cpufrequtils
            if (whiptail --title "Yes/No" --yesno "
Uninstall cpufrequtils?
卸載cpufrequtils?
                " 10 60 ) then
                apt -y remove cpufrequtils 2>&1 &
                sed -i 's/ intel_pstate=disable//g' /etc/default/grub
                rm -rf /etc/default/cpufrequtils
            fi
            whiptail --title "Success" --msgbox "
Done
配置完成
            " 10 60
        fi
        chCpu
    esac
fi
#-------------chCpu--main--end------------

}

chSubs(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Remove subscribe notice." \
    "b" "Unset config." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "安裝配置CPU省電" 25 60 15 \
    "a" "去除訂閱提示" \
    "b" "還原配置" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a )
        if(whiptail --title "Yes/No" --yesno "
continue?
是否去除訂閱提示?
            " 10 60 )then
            #whiptail --title " in " --msgbox "$bver $cver  $dver" 10 60
            if [ `grep "data.status.toLowerCase() !== 'active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 1 ];then
                sed -i.bak "s/data.status.toLowerCase() !== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                whiptail --title "Success" --msgbox "
Done!!
去除成功！
                " 10 60
            elif [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 1 ];then
                    sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                    whiptail --title "Success" --msgbox "
Done!!
去除成功！
                    " 10 60
            else
                whiptail --title "Success" --msgbox "
You already removed.
已經去除過了，不需要再次去除。
                " 10 60
            fi
        fi
        ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
continue?
是否還原訂閱提示?
            " 10 60) then
            if [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 0 ];then
                mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                whiptail --title "Success" --msgbox "
Done!!
還原成功！
                " 10 60
            else
                whiptail --title "Success" --msgbox "
You already removed.
已經還原過了，不需要再次還原。
                " 10 60
            fi
        fi
        ;;
    esac
fi
}
chSmartd(){
  hds=`lsblk|grep "^[s,h]d[a-z]"|awk '{print $1}'`
}

chNestedV(){
clear
unsetVmN(){
    list=`qm list|awk 'NR>1{print $1":"$2"......."$3" "}'`
    ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}';done`
    h=`echo $ls|wc -l`
    let h=$h*1
    if [ $h -lt 30 ];then
        h=30
    fi
    list1=`echo $list|awk 'NR>1{print $1}'`
    vmid=$(whiptail  --title " PveTools   Version : 2.2.5 " --menu "
Choose vmid to unset nested:
選擇需要關閉嵌套虛拟化的vm：" 25 60 15 \
    $(echo $ls) \
     3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
你選的是：$vmid ，是否繼續?
            " 10 60)then
            while [ true ]
            do
                if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
    輸入格式錯誤，請重新輸入：
                    " 10 60
                    setVmN
                else
                    break
                fi
            done
            if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                whiptail --title "Success" --msgbox "
    You already unseted.Nothing to do.
    您的虛拟機未開啓過嵌套虛拟化支持。
                " 10 60
            else
                args=`qm showcmd $vmid|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                sed -i '/,+vmx/d' /etc/pve/qemu-server/$vmid.conf
                echo  "args: "$args >> /etc/pve/qemu-server/$vmid.conf
                whiptail --title "Success" --msgbox "
    Unset OK.Please reboot your vm.
    您的虛拟機已經關閉嵌套虛拟化支持。重啓虛拟機後生效。
                " 10 60
            fi
        else
            chNestedV
        fi
    else
        chNestedV
    fi
}
setVmN(){
    list=`qm list|awk 'NR>1{print $1":"$2"......."$3" "}'`
    ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}';done`
    h=`echo $ls|wc -l`
    let h=$h*1
    if [ $h -lt 30 ];then
        h=30
    fi
    list1=`echo $list|awk 'NR>1{print $1}'`
    vmid=$(whiptail  --title " PveTools   Version : 2.2.5 " --menu "
Choose vmid to set nested:
選擇需要配置嵌套虛拟化的vm：" 25 60 15 \
    $(echo $ls) \
     3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
你選的是：$vmid ，是否繼續?
            " 10 60)then
            while [ true ]
            do
                if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
    輸入格式錯誤，請重新輸入：
                    " 10 60
                    setVmN
                else
                    break
                fi
            done
            if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                args=`qm showcmd $vmid|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                for i in 'boot:' 'memory:' 'core:';do
                    if [ `grep '^'$i /etc/pve/qemu-server/$vmid.conf|wc -l` -gt 0 ];then
                        con=$i
                        break
                    fi
                done
                sed "/"$con"/a\args: $args,+vmx" -i /etc/pve/qemu-server/$vmid.conf
                #echo "args: "$args",+vmx" >> /etc/pve/qemu-server/$vmid.conf
                whiptail --title "Success" --msgbox "
    Nested OK.Please reboot your vm.
    您的虛拟機已經開啓嵌套虛拟化支持。重啓虛拟機後生效。
                " 10 60
            else
                whiptail --title "Success" --msgbox "
    You already seted.Nothing to do.
    您的虛拟機已經開啓過嵌套虛拟化支持。
                " 10 60
            fi
        else
            chNestedV
        fi
    else
        chNestedV
    fi
}
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config Nested:" 25 60 15 \
    "a" "Enable nested" \
    "b" "Set vm to nested" \
    "c" "Unset vm nested" \
    "d" "Disable nested" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置嵌套虛拟化:" 25 60 15 \
    "a" "開啓嵌套虛拟化" \
    "b" "開啓某個虛拟機的嵌套虛拟化" \
    "c" "關閉某個虛拟機的嵌套虛拟化" \
    "d" "關閉嵌套虛拟化" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
        a )
            if(whiptail --title "Yes/No" --yesno "
Are you sure to enable Nested?
It will stop all your runnging vms (Y/n):
确定要開啓嵌套虛拟化嗎？
這個操作會停止你現在所有運行中的虛拟機!(Y/n):
            " 10 60) then
                if [ `cat /sys/module/kvm_intel/parameters/nested` = 'N' ];then
                    for i in `qm list|awk 'NR>1{print $1}'`;do
                        qm stop $i
                    done
                    modprobe -r kvm_intel
                    modprobe kvm_intel nested=1
                    if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                        echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf
                        whiptail --title "Success" --msgbox "
Nested ok.
您已經開啓嵌套虛拟化。
                        " 10 60
                    else
                        whiptail --title "Warnning" --msgbox "
Your system can not open nested.
您的系統不支持嵌套虛拟化。
                        " 10 60
                    fi
                else
                    whiptail --title "Warnning" --msgbox "
You already enabled nested virtualization.
您已經開啓過嵌套虛拟化。
                    " 10 60
                fi
            fi
            chNestedV
            ;;
        b )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                if [ `qm list|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
You have no vm.
您還沒有虛拟機。
                    " 10 60
                else
                    setVmN
                fi
                chNestedV
            else
                whiptail --title "Warnning" --msgbox "
Your system can not open nested.
您的系統不支持嵌套虛拟化。
                " 10 60
                chNestedV
            fi
            ;;
        c )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                if [ `qm list|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
You have no vm.
您還沒有虛拟機。
                    " 10 60
                else
                    unsetVmN
                fi
                chNestedV
            else
                whiptail --title "Warnning" --msgbox "
Your system can not open nested.
您的系統不支持嵌套虛拟化。
                " 10 60
                chNestedV
            fi
            ;;
        q )
            main
            ;;
    esac
else
    main
fi
}
chSensors(){
#安裝lm-sensors并配置在界面上顯示
#for i in `sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`;do modprobe $i;done
clear
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config lm-sensors & proxmox ve display:" 25 60 15 \
    "a" "Install." \
    "b" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置Sensors:" 25 60 15 \
    "a" "安裝配置溫度顯示" \
    "b" "删除配置" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        if(whiptail --title "Yes/No" --yesno "
Your OS：$pve, you will install sensors interface, continue?(y/n)
您的系統是：$pve, 您将安裝sensors界面，是否繼續？(y/n)
            " 10 60) then
            js='/usr/share/pve-manager/js/pvemanagerlib.js'
            pm='/usr/share/perl5/PVE/API2/Nodes.pm'
            sh='/usr/bin/s.sh'
            ppv=`/usr/bin/pveversion`
            OS=`echo $ppv|awk -F'-' 'NR==1{print $1}'`
            ver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
            bver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'`
            pve=$OS$ver
            if [[ "$OS" != "pve" ]];then
                whiptail --title "Warnning" --msgbox "
您的系統不是Proxmox VE, 無法安裝!
Your OS is not Proxmox VE!
                " 10 60
                if [[ "$bver" != "5" || "$bver" != "6" ]];then
                    whiptail --title "Warnning" --msgbox "
您的系統版本無法安裝!
Your Proxmox VE version can not install!
                    " 10 60
                    main
                fi
                main
            fi
            if [[ ! -f "$js" || ! -f "$pm" ]];then
                whiptail --title "Warnning" --msgbox "
您的Proxmox VE版本不支持此方式！
Your Proxmox VE\'s version is not supported,Now quit!
                " 10 60
                main
            fi
            #if [[ -f "$js.backup" && -f "$sh" ]];then
            if [[ `cat $js|grep Sensors|wc -l` -gt 0 ]];then
                whiptail --title "Warnning" --msgbox "
您已經安裝過本軟件，請不要重複安裝！
You already installed,Now quit!
                " 10 60
                chSensors
            fi
            if [ ! -f "/usr/bin/sensors" ];then
                apt-get -y install lm-sensors
            fi
            sensors-detect --auto > /tmp/sensors
            drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
            if [ `echo $drivers|wc -w` = 0 ];then
                whiptail --title "Warnning" --msgbox "
Sensors driver not found.
沒有找到任何驅動，似乎你的系統不支持。
                " 10 60
                chSensors
            else
                for i in $drivers
                do
                    modprobe $i
                    if [ `grep $i /etc/modules|wc -l` = 0 ];then
                        echo $i >> /etc/modules
                    fi
                done
                sensors
                sleep 3
                whiptail --title "Success" --msgbox "
Install complete,if everything ok ,it\'s showed sensors.Next, restart you web.
安裝配置成功，如果沒有意外，上面已經顯示sensors。下一步會重啓web界面，請不要驚慌。
                " 20 60
            fi
            rm /tmp/sensors
            cp $js $js.backup
            cp $pm $pm.backup
            cat << EOF > /usr/bin/s.sh
r=\`sensors|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/:/":"/g'|sed 's/^/"/g' |sed 's/$/",/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/,$//g'|sed 's/°C/C/g'\`
r="{"\$r"}"
echo \$r
EOF
            chmod +x /usr/bin/s.sh
            #--create the configs--
            d=`sensors|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk -F ":" '{print $1}'`
            if [ -f ./p1 ];then rm ./p1;fi
            cat << EOF >> ./p1
        ,{
            xtype: 'box',
            colspan: 2,
        title: gettext('Sensors Data:'),
            padding: '0 0 20 0'
        }
        ,{
            itemId: 'Sensors',
            colspan: 2,
            printBar: false,
            title: gettext('Sensors Data:')
        }
EOF
            for i in $d
            do
            cat << EOF >> ./p1
        ,{
            itemId: '$i',
            colspan: 1,
            printBar: false,
            title: gettext('$i'),
            textField: 'tdata',
            renderer:function(value){
            var d = JSON.parse(value);
            var s = "";
            s = d['$i'];
            return s;
            }
        }
EOF
            done
            cat << EOF >> ./p2
\$res->{tdata} = \`/usr/bin/s.sh\`;
EOF
            #--configs end--
            #h=`sensors|awk 'END{print NR}'`
            itemC=`s.sh|sed  's/\,/\r\n/g'|wc -l`
            if [ $h = 0 ];then
                h=400
            else
                #let h=$h*9+320
                let h=$itemC*24/2+360
            fi
            n=`sed '/widget.pveNodeStatus/,/height/=' $js -n|sed -n '$p'`
            sed -i ''$n'c \ \ \ \ height:\ '$h',' $js
            n=`sed '/pveversion/,/\}/=' $js -n|sed -n '$p'`
            sed -i ''$n' r ./p1' $js
            n=`sed '/pveversion/,/version_text/=' $pm -n|sed -n '$p'`
            sed -i ''$n' r ./p2' $pm
            if [ -f ./p1 ];then rm ./p1;fi
            if [ -f ./p2 ];then rm ./p2;fi
            systemctl restart pveproxy
            whiptail --title "Success" --msgbox "
如果沒有意外，已經安裝完成！浏覽器打開界面刷新看一下概要界面！
Installation Complete! Go to websites and refresh to enjoy!
            " 10 60
        else
            chSensors
        fi
    ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
Uninstall?
确認要還原配置？
        " 10 60)then
            js='/usr/share/pve-manager/js/pvemanagerlib.js'
            pm='/usr/share/perl5/PVE/API2/Nodes.pm'
            if [[ ! -f $js.backup && ! -f /usr/bin/sensors ]];then
                whiptail --title "Warnning" --msgbox "
    No sensors found.
    沒有檢測到安裝，不需要卸載。
                " 10 60
            else
                sensors-detect --auto > /tmp/sensors
                drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
                if [ `echo $drivers|wc -w` != 0 ];then
                    for i in $drivers
                    do
                        if [ `grep $i /etc/modules|wc -l` != 0 ];then
                            sed -i '/'$i'/d' /etc/modules
                        fi
                    done
                fi
                apt-get -y remove lm-sensors
            {
                mv $js.backup $js
                mv $pm.backup $pm
                echo 50
                echo 100
                sleep 1
            }|whiptail --gauge "Uninstalling" 10 60 0
            whiptail --title "Success" --msgbox "
Uninstall complete.
卸載成功。
            " 10 60
            fi
        fi
        chSensors
        ;;
    esac
fi
}

chPassth(){

#--------------funcs-start----------------
enablePass(){
if(whiptail --title "Yes/No Box" --yesno "
Enable PCI Passthrough(need reboot host)?
是否開啓硬件直通支持（需要重啓物理機）?
" --defaultno 10 60) then
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "
Your hardware do not support PCI Passthrough(No IOMMU)
您的硬件不支持直通！
" 10 60
        chPassth
    fi
    if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
        iommu="amd_iommu=on"
    else
        iommu="intel_iommu=on"
    fi
    if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet '$iommu'|' /etc/default/grub
        update-grub
        if [ `grep "vfio" /etc/modules|wc -l` = 0 ];then
            cat <<EOF >> /etc/modules
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF
        fi
        whiptail --title "Success" --msgbox "
    need to reboot to apply! Please reboot.
    安裝好後需要重啓系統，請稍後重啓。
        " 10 60
    else
        whiptail --title "Warnning" --msgbox "
You already configed!
您已經配置過這個了!
" 10 60
        chPassth
    fi
else
    main
fi
}

disablePass(){
if(whiptail --title "Yes/No Box" --yesno "
disable PCI Passthrough(need reboot host)?
是否關閉硬件直通支持（需要重啓物理機）?
" --defaultno 10 60) then
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --yesno "
Your hardware do not support PCI Passthrough(No IOMMU)
您的硬件不支持直通！
" 10 60
        chPassth
    fi
    if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
        iommu='amd_iommu=on'
    else
        iommu='intel_iommu=on'
    fi
    if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "not config yet.
您還沒有配置過該項" 10 60
        chPassth
    else
        update-grub
    {
        sed -i 's/ '$iommu'//g' /etc/default/grub
        echo 30
        echo 80
        sed -i '/vfio/d' /etc/modules
        echo 100
        sleep 1
        }|whiptail --gauge "installing..." 10 60 10
        whiptail --title "Success" --msgbox "
need to reboot to apply! Please reboot.
安裝好後需要重啓系統，請稍後重啓。
        " 10 60
    fi
else
    main
fi
}

enVideo(){
    clear
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "
    Your hardware do not support PCI Passthrough(No IOMMU)
    您的硬件不支持直通！
    " 10 60
        configVideo
    fi
    if [ `grep 'iommu=on' /etc/default/grub|wc -l` = 0 ];then
        if(whiptail --title "Warnning" --yesno "
    your host not enable IOMMU,jump to enable?
    您的主機系統尚未配置直通支持，跳轉去設置？
        " 10 60)then
            enablePass
        fi
    fi
    if [ `grep 'vfio' /etc/modules|wc -l` = 0 ];then
        if(whiptail --title "Warnning" --yesno "
    your host not enable IOMMU,jump to enable?
    您的主機系統尚未配置直通支持，跳轉去設置？
        " 10 60)then
            enablePass
        fi
    fi
    getVideo

}

getVideo(){
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -E 'VGA|Audio' > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cat cards-out > cards
    id=`cat /etc/modprobe.d/vfio.conf|grep -o "ids=[0-9a-zA-Z,:]*"|awk -F "=" '{print $2}'|sed  's/,/ /g'|sort -u`
    n=`for i in $id;do lspci -n -d $i|awk -F "." '{print $1}';done|sort -u`
    for i in $n
    do
        cards=`sed -n '/'$i'/ s/OFF/ON/p' cards`
    done
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config(* mark means configed):
選擇顯卡（标*号爲已經配置過的）：
" 15 90 4 \
$(echo $cards) \
3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
	    rm cards*
            if(whiptail --title "Warnning" --yesno "
Continue?
請确認是否繼續？
            " 10 60)then
                clear
            else
                getVideo
            fi
            ids=""
            for i in $DISTROS
            do
                i=`echo $i|sed 's/\"//g'`
                ids=$ids`lspci -n -s ${i}|awk '{print ","$3}'`
            done
            ids=`echo $ids|sed 's/^,//g'|sed 's/ ,/,/g'`
            if [ `grep $ids'$' /etc/modprobe.d/vfio.conf|wc -l` = 0 ];then
                echo "options vfio-pci ids=$ids" > /etc/modprobe.d/vfio.conf
            else
                if(whiptail --defaultno --title "Warnning" --yesno "
    It seems you have already configed it before.Reconfig?
    您好像已經配置過這個了。重新配置？
                " 10 60)then
                    clear
                else
                   getVideo
                fi
            fi
            #--config-blacklist--
            for i in nvidiafb nouveau nvidia radeon amdgpu
            do
                if [ `grep '^blacklist '$i'$' /etc/modprobe.d/pve-blacklist.conf|wc -l` = 0 ];then
                    echo "blacklist "$i >> /etc/modprobe.d/pve-blacklist.conf
                fi
            done
            #--iommu-groups--
            if [ `find /sys/kernel/iommu_groups/ -type l|wc -l` = 0 ];then
                if [ `grep 'pcie_acs_override=downstream' /etc/default/grub|wc -l` = 0 ];then
                    sed -i.bak 's|iommu=on|iommu=on 'iommu=pt pcie_acs_override=downstream'|' /etc/default/grub
                    update-grub
                fi
            fi
            #--video=efifb:off--
            if [ `grep 'video=efifb:off' /etc/default/grub|wc -l` = 0 ];then
                sed -i.bak 's|quiet|quiet video=efifb:off|' /etc/default/grub
                update-grub
            fi
            #--kvm-parameters--
            if [ `cat /sys/module/kvm/parameters/ignore_msrs` = 'N' ];then
                echo 1 > /sys/module/kvm/parameters/ignore_msrs
                echo "options kvm ignore_msrs=Y">>/etc/modprobe.d/kvm.conf
            fi
            update-initramfs -u -k all
            whiptail --title "Success" --msgbox "
    need to reboot to apply! Please reboot.
    安裝好後需要重啓系統，請稍後重啓。
            " 10 60
        else
            if(whiptail --title "Warnning" --yesno "
Continue?
請确認是否繼續？
            " 10 60)then
                clear
            else
                getVideo
            fi
            {
            echo "" > /etc/modprobe.d/vfio.conf
            echo 0 > /sys/module/kvm/parameters/ignore_msrs
            sed -i '/ignore_msrs=Y/d' /etc/modprobe.d/kvm.conf
            for i in nvidiafb nouveau nvidia radeon amdgpu
            do
                sed -i '/'$i'/d' /etc/modprobe.d/pve-blacklist.conf
            done
            echo 100
            sleep 1
            }|whiptail --gauge "configing..." 10 60 10
            whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
        fi
    else
        configVideo
    fi
}

disVideo(){
    clear
    getVideo dis
}
addVideo(){
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -e VGA > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cards=`cat cards-out`
    rm cards*
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config?" 15 90 4 \
$(echo $cards) \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            confPath='/etc/pve/qemu-server/'
            ids=""
            for i in $DISTROS
            do

                i=`echo $i|sed 's/\"//g'`
                for j in `ls $confPath`
                do
                    if [ `grep $i $confPath$j|wc -l` != 0 ];then
                        confId=`echo $j|awk -F '.' '{print $1}'`
                    fi
                done
            done
            list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
            echo -n "">lsvm
            ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2" OFF"}'>>lsvm;done`
            ls=`sed -i '/'$confId'/ s/OFF/ON/g' lsvm`
            ls=`cat lsvm`
            rm lsvm
            h=`echo $ls|wc -l`
            let h=$h*1
            if [ $h -lt 30 ];then
                h=30
            fi
            list1=`echo $list|awk 'NR>1{print $1}'`
            vmid=$(whiptail  --title " PveTools   Version : 2.2.5 " --radiolist "
        Choose vmid to set video card Passthrough:
        選擇需要配置顯卡直通的vm：" 20 60 10 \
            $(echo $ls) \
            3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                if(whiptail --title "Yes/No" --yesno "
        you choose: $vmid ,continue?
        你選的是：$vmid ，是否繼續?
                    " 10 60)then
                    echo $vmid>vmid
                    while [ true ]
                    do
                        if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                            whiptail --title "Warnning" --msgbox "
            輸入格式錯誤，請重新輸入：
                            " 10 60
                            addVideo
                        else
                            break
                        fi
                    done
                    if [ $vmid -eq $confId ];then
                        whiptail --title "Warnning" --msgbox "
You already configed!
您已經配置過這個了!
                        " 10 60
                        addVideo
                    fi
                    opt=$(whiptail  --title " PveTools   Version : 2.2.5 " --checklist "
Choose options:
選擇選項：" 20 60 10 \
                    "q35" "q35支持，gpu直通建議選擇，獨顯留空" OFF \
                    "ovmf" "gpu直通選擇" OFF \
                    "x-vga" "主gpu，默認已選擇" ON \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in 'boot:' 'memory:' 'core:';do
                            if [ `grep '^'$i $confPath$vmid.conf|wc -l` != 0 ];then
                                con=$i
                                break
                            fi
                        done
                        for op in $opt
                        do
                            op=`echo $op|sed 's/\"//g'`
                            if [ $op = 'q35' ];then
                                sed "/"$con"/a\machine\: q35" -i $confPath$vmid.conf
                            fi
                            if [ $op = 'ovmf' ];then
                                sed "/"$con"/a\bios\: ovmf" -i $confPath$vmid.conf
                            fi
                        done
                        #--config-vmid.conf---
                        for i in $DISTROS
                        do
                            if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` = 0 ];then
                                pcid=`cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|awk -F ':' '{print $1}'|sort -u|grep '[0-9]*$' -o`
                                if [ $pcid ];then
                                    pcid=$((pcid+1))
                                else
                                    pcid=0
                                fi
                                i=`echo $i|sed 's/\"//g'`
                                sed -i "/"$con"/a\hostpci"$pcid": "$i",x-vga=1" $confPath$vmid.conf
                            else
                                whiptail --title "Warnning" --msgbox "
You already configed!
您已經配置過這個了!
                                " 10 60
                            fi
                            if [ $confId ];then
                                rmVideo $confId $confPath $i
                            fi
                            whiptail --title "Success" --msgbox "
Configed!Please reboot vm.
配置成功！重啓虛拟機後生效。
                            " 10 60
                            if(whiptail --title "Yes/No" --yesno "
Let tool auto switch vm?
是否自動幫你重啓切換虛拟機？" 10 60)then
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                if [ $confId ];then
                                    usb=`cat /etc/pve/qemu-server/115.conf |grep '^usb'|wc -l`
                                    if [ $usb ];then
                                        if(whiptail --title "Yes/No" --yesno "
Let tool auto switch usb?
是否自動切換usb設備？
                                        " 10 60)then
                                            cat $confPath$confId.conf |grep '^usb'|sed 's/ //g'>usb
                                            sed -i '/^usb/d' $confPath$confId.conf
                                            for i in `cat usb`;do sed -i '/memory/a\'$i $confPath$vmid.conf;done
                                            sed -i 's/:host/: host/g' $confPath$vmid.conf
                                            rm usb
                                        fi
                                    fi
                                    qm stop $confId
                                fi
                                qm stop $vmid
                                if [ $confId ];then
                                    qm start $confId
                                fi
                                qm start $vmid
                            whiptail --title "Success" --msgbox "
Configed!
配置成功！
                            " 10 60
                            else
                                configVideo
                            fi
                        done
                    else
                        addVideo
                    fi
                    configVideo
                else
                    addVideo
                fi
            else
                configVideo
            fi
        else
            whiptail --title "Warnning" --msgbox "
Please choose a card.
請選擇一個顯卡。" 10 60
            addVideo
        fi
    else
        configVideo
    fi
}
rmVideo(){
    clear
    vmid=$1
    confPath=$2
    DISTROS=$3
    for i in $vmid
    do
        sed -i '/q35/d' $confPath$vmid.conf
        for i in $DISTROS
            do
                if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` != 0 ];then
                    sed -i '/'$i'/d' $confPath$vmid.conf
                fi
            done
    done
}
switchVideo(){
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -e VGA > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cards=`cat cards-out`
    rm cards*
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config?" 15 90 4 \
$(echo $cards) \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            confPath='/etc/pve/qemu-server/'
            ids=""
            for i in $DISTROS
            do

                i=`echo $i|sed 's/\"//g'`
                for j in `ls $confPath`
                do
                    if [ `grep $i $confPath$j|wc -l` != 0 ];then
                        confId=`echo $j|awk -F '.' '{print $1}'`
                    fi
                done
            done
            list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
            echo -n "">lsvm
            ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2" OFF"}'>>lsvm;done`
            ls=`sed -i '/'$confId'/ s/OFF/ON/g' lsvm`
            ls=`cat lsvm`
            rm lsvm
            h=`echo $ls|wc -l`
            let h=$h*1
            if [ $h -lt 30 ];then
                h=30
            fi
            list1=`echo $list|awk 'NR>1{print $1}'`
            vmid=$(whiptail  --title " PveTools   Version : 2.2.5 " --radiolist "
        Choose vmid to set video card Passthrough:
        選擇需要配置顯卡直通的vm：" 20 60 10 \
            $(echo $ls) \
            3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                if(whiptail --title "Yes/No" --yesno "
        you choose: $vmid ,continue?
        你選的是：$vmid ，是否繼續?
                    " 10 60)then
                    echo $vmid>vmid
                    while [ true ]
                    do
                        if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                            whiptail --title "Warnning" --msgbox "
            輸入格式錯誤，請重新輸入：
                            " 10 60
                            addVideo
                        else
                            break
                        fi
                    done
                    if [ $vmid -eq $confId ];then
                        whiptail --title "Warnning" --msgbox "
You already configed!
您已經配置過這個了!
                        " 10 60
                        addVideo
                    fi
                    opt=$(whiptail  --title " PveTools   Version : 2.2.5 " --checklist "
Choose options:
選擇選項：" 20 60 10 \
                    "q35" "q35支持，gpu直通建議選擇，獨顯留空" OFF \
                    "ovmf" "gpu直通選擇" OFF \
                    "x-vga" "主gpu，默認已選擇" ON \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in 'boot:' 'memory:' 'core:';do
                            if [ `grep '^'$i $confPath$vmid.conf|wc -l` != 0 ];then
                                con=$i
                                break
                            fi
                        done
                        for op in $opt
                        do
                            op=`echo $op|sed 's/\"//g'`
                            if [ $op = 'q35' ];then
                                sed "/"$con"/a\machine\: q35" -i $confPath$vmid.conf
                            fi
                            if [ $op = 'ovmf' ];then
                                sed "/"$con"/a\bios\: ovmf" -i $confPath$vmid.conf
                            fi
                        done
                        #--config-vmid.conf---
                        for i in $DISTROS
                        do
                            if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` = 0 ];then
                                pcid=`cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|awk -F ':' '{print $1}'|sort -u|grep '[0-9]*$' -o`
                                if [ $pcid ];then
                                    pcid=$((pcid+1))
                                else
                                    pcid=0
                                fi
                                i=`echo $i|sed 's/\"//g'`
                                sed -i "/"$con"/a\hostpci"$pcid": "$i",x-vga=1" $confPath$vmid.conf
                            else
                                whiptail --title "Warnning" --msgbox "
You already configed!
您已經配置過這個了!
                                " 10 60
                            fi
                            if [ $confId ];then
                                rmVideo $confId $confPath $i
                            fi
                            whiptail --title "Success" --msgbox "
Configed!Please reboot vm.
配置成功！重啓虛拟機後生效。
                            " 10 60
                            if(whiptail --title "Yes/No" --yesno "
Let tool auto switch vm?
是否讓工具自動幫你重啓切換虛拟機？" 10 60)then
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                qm stop $confId
                                qm stop $vmid
                                qm start $confId
                                qm start $vmid
                                whiptail --title "Success" --msgbox "
Configed!
配置成功！
                                " 10 60
                            else
                                configVideo
                            fi
                        done
                    else
                        addVideo
                    fi
                    configVideo
                else
                    addVideo
                fi
            else
                configVideo
            fi
        else
            whiptail --title "Warnning" --msgbox "
Please choose a card.
請選擇一個顯卡。" 10 60
            addVideo
        fi
    else
        configVideo
    fi
}

configVideo(){
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config PCI Video card Passthrough:" 25 60 15 \
    "a" "Config Video Card Passthrough" \
    "b" "Config Video Card Passthrough to vm" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置PCI顯卡直通:" 25 60 15 \
    "a" "配置物理機顯卡直通支持。" \
    "b" "配置顯卡直通給虛拟機。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        enVideo
        ;;
    b )
        addVideo
        ;;
    esac
else
    main
fi
}


#--------------funcs-end----------------

if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config PCI Passthrough:" 25 60 15 \
    "a" "Config IOMMU on." \
    "b" "Config IOMMU off." \
    "c" "Config Video Card Passthrough" \
    "d" "Config qm set disks." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置硬件直通:" 25 60 15 \
    "a" "配置開啓物理機硬件直通支持。" \
    "b" "配置關閉物理機硬件直通支持。" \
    "c" "配置顯卡直通。" \
    "d" "配置qm set 硬盤給虛拟機。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        enablePass
        ;;
    b )
        disablePass
        ;;
    c )
        configVideo
        ;;
    d )
        chQmdisk
    esac
else
    main
fi
}

checkPath(){
    x=$(whiptail --title "Choose a path" --inputbox "
Input path:
請輸入路徑：" 10 60 \
    $1 \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ ! -d $x ];then
                whiptail --title "Warnning" --msgbox "Path not found.
沒有檢測到路徑，請重新輸入" 10 60
                checkPath
            else
                break
            fi
        done
        echo $x
        return $?
    fi
}

chRoot(){
    #--base-funcs-start--
    setChroot(){
        clear
        if(whiptail --title "Yes/No" --yesno "
Continue?
是否繼續？" --defaultno 10 60 )then
            if [ ! -f "/usr/bin/schroot" ];then
                whiptail --title "Warnning" --msgbox "you not installed schroot.
您還沒有安裝schroot。" 10 60
                if [ `ps aux|grep apt-get|wc -l` -gt 1 ];then
                    if(whiptail --title "Yes/No" --yesno "apt-get is running,killit and install schroot?
後台有apt-get正在運行，是否殺掉進行安裝？
                    " 10 60);then
                        killall apt-get && apt-get -y install schroot
                    else
                        setChroot
                    fi
                else
                    apt-get -y install schroot
                fi
            fi
            sed '/^$/d' /etc/schroot/default/fstab
            if [ `grep '\/run\/udev' /etc/schroot/default/fstab|wc -l` = 0 ];then
                cat << EOF >> /etc/schroot/default/fstab
/run/udev       /run/udev       none    rw,bind         0       0
EOF
            fi
            if [ `grep '\/sys\/fs\/cgroup' /etc/schroot/default/fstab|wc -l` = 0 ];then
                sed '/cgroup/d' /etc/schroot/default/fstab
                cat << EOF >> /etc/schroot/default/fstab
/sys/fs/cgroup  /sys/fs/cgroup  none    rw,rbind        0       0
EOF
            fi
            sed -i '/\/home/d' /etc/schroot/default/fstab
            checkPath /
            chrootp=${x%/}"/alpine"
            echo $chrootp > /etc/schroot/chrootp
            if [ ! -d $chrootp ];then
                mkdir $chrootp
            else
                clear
            fi
            cd $chrootp
            if [ `ls $chrootp/bin|wc -l` -gt 0 ];then
                if(whiptail --title "Warnning" --yesno "files exist, remove and reinstall?
已經存在文件，是否清空重裝？" --defaultno 10 60)then
                    for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
                    killall dockerd
                    killall portainer
                    rm -rf $chrootp/*
                else
                    configChroot
                fi
            fi
            if [ $L = "en" ];then
                alpineUrl='http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64'
            else
                alpineUrl='https://mirrors.aliyun.com/alpine/v3.10/releases/x86_64'
            fi
            version=`wget $alpineUrl/ -q -O -|grep minirootfs|grep -o '[0-9]*\.[0-9]*\.[0-9]*'|sort -u -r|awk 'NR==1{print $1}'`
            echo $alpineUrl
            echo $version
            sleep 3
            wget -c --timeout 15 --waitretry 5 --tries 5 $alpineUrl/alpine-minirootfs-$version-x86_64.tar.gz
            tar -xvzf alpine-minirootfs-$version-x86_64.tar.gz
            rm -rf alpine-minirootfs-$version-x86_64.tar.gz
            if [ ! -f "/etc/schroot/chroot.d/alpine.conf" ] || [ `cat /etc/schroot/chroot.d/alpine.conf|wc -l` -lt 8 ];then
                cat << EOF > /etc/schroot/chroot.d/alpine.conf
[alpine]
description=alpine $version
directory=$chrootp
users=root
groups=root
root-users=root
root-groups=root
type=directory
shell=/bin/sh
EOF
            fi
            echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > $chrootp/etc/apk/repositories \
            && echo "http://mirrors.aliyun.com/alpine/latest-stable/community/"  >> $chrootp/etc/apk/repositories
            cat << EOF >> $chrootp/etc/profile
echo "Welcome to alpine $version chroot."
echo "Create by PveTools."
echo "Author: 龍天ivan"
echo "Github: https://github.com/ivanhao/pvetoools"
EOF
            schroot -c alpine apk update
            whiptail --title "Success" --msgbox "Done.
安裝配置完成！" 10 60
            docker
            dockerWeb
            configChroot
        else
            configChroot
        fi
    }
    installOs(){
        clear
    }
    enterChroot(){
        clear
        checkSchroot
        c=`schroot -l|awk -F ":" '{print $2"  "$1}'`
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Enter chroot:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "進入chroot環境:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if [ $x ];then
                schroot -c $x -d /root
            else
                chRoot
            fi
        else
            chRoot
        fi
    }
    docker(){
        clear
        checkSchroot
        if [ `schroot -c alpine -d /root ls /usr/bin|grep docker|wc -l` = 0 ];then
            if(whiptail --title "Warnning" --yesno "No docker found.Install?
您還沒有安裝docker,是否安裝？" 10 60)then
                schroot -c alpine -d /root apk update
                schroot -c alpine -d /root apk add docker
                cat << EOF >> $chrootp/etc/profile
export DOCKER_RAMDISK=true
echo "Docker installed."
for i in {1..10}
do
if [ \`ps aux|grep dockerd|wc -l\` -gt 1 ];then
    break
else
    nohup /usr/bin/dockerd > /dev/null 2>&1 &
fi
done
EOF
                if [ ! -d "$chrootp/etc/docker" ];then
                    mkdir $chrootp/etc/docker
                fi
                if [ $L = "en" ];then
                    cat << EOF > $chrootp/etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://dockerhub.azk8s.cn",
        "https://reg-mirror.qiniu.com",
        "https://registry.docker-cn.com"
    ]
}
EOF
                fi
            else
                configChroot
            fi
        fi
        if [ -f "/usr/bin/screen" ];then
            apt-get install screen -y
        fi
        if [ `screen -ls|grep docker|wc -l` != 0 ];then
            screen -S docker -X quit
        fi
        if(whiptail --title "Yes/No" --yesno "Install portainer web interface?
是否安裝web界面（portainer）？" 10 60);then
            dockerWeb
        else
            clear
        fi
        screen -dmS docker schroot -c alpine -d /root
        configChroot
    }
    dockerWeb(){
        checkSchroot
        checkDocker
        checkDockerWeb
        if [ `cat $chrootp/etc/profile|grep portainer|wc -l` = 0 ];then
            cat << EOF >> $chrootp/etc/profile
if [ ! -d "/root/portainer_data" ];then
    mkdir /root/portainer_data
fi
if [ \`docker ps -a|grep portainer|wc -l\` = 0 ];then
    docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /root/portainer_data:/data portainer/portainer
else
    docker start portainer > /dev/null
fi
echo "Portainer installed."
EOF
        fi

        if [ ! -f "/usr/bin/screen" ];then
            apt-get install screen -y
        fi
        chrootReDaemon
        sleep 5
        if [ `schroot -c alpine -d /root docker images|grep portainer|wc -l` = 0 ];then
            schroot -c alpine -d /root docker pull portainer/portainer
        fi
        if [ `schroot -c alpine -d /root docker ps -a|grep portainer|wc -l` = 0 ];then
            schroot -c alpine -d /root docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /root/portainer_data:/data portainer/portainer
        fi
        checkDockerWeb
    }
    checkSchroot(){
        if [ `ls /usr/bin|grep schroot|wc -l` = 0 ] || [ `schroot -l|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No schroot found.Install schroot first.
您還沒有安裝schroot環境，請先安裝。" 10 60
            chRoot
        else
            if [ -f "/etc/schroot/chrootp" ];then
                chrootp=`cat /etc/schroot/chrootp`
            else
                if [ -d "/alpine" ];then
                    chrootp="/alpine"
                    echo $chrootp > /etc/schroot/chrootp
                else
                    whiptail --title "Warnning" --msgbox "Chroot path not found!
沒有檢測到chroot安裝目錄！" 10 60
                fi
            fi
        fi
    }
    checkDocker(){
        if [ `ls $chrootp/usr/bin|grep docker|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No docker found.Install docker first.
您還沒有安裝docker環境，請先安裝。" 10 60
            chRoot
        fi
    }
    checkDockerWeb(){
        if [ `schroot -c alpine -d /root docker images|grep portainer|wc -l` != 0 ];then
            whiptail --title "Warnning" --msgbox "DockerWeb found.Quit.
您已經安裝dockerWeb環境。
請進入http://ip:9000使用。
" 10 60
            chRoot
        fi
    }
    chrootReDaemon(){
        if [ `screen -ls|grep docker|wc -l` != 0 ];then
            for i in `screen -ls|grep docker|awk -F " " '{print $1}'|awk -F "." '{print $1}'`
            do
                screen -S $i -X quit
            done
        fi
        screen -dmS docker schroot -c alpine -d /root
        if [ `cat /etc/crontab|grep schroot|wc -l` = 0 ];then
            cat << EOF >> /etc/crontab
@reboot  root  screen -dmS docker schroot -c alpine -d /root
EOF
        fi
        whiptail --title "Success" --msgbox "Chroot daemon done." 10 60
    }
    checkChrootDaemon(){
        if [ `screen -ls|grep docker|wc -l` = 0 ];then
            screen -dmS docker schroot -c alpine -d /root
            if [ `screen -ls|grep docker|wc -l` != 0 ];then
                whiptail --title "Warnning" --msgbox "Chroot daemon started.
已經爲您開啓chroot後台運行環境。
                " 10 60
                chRoot
            else
                checkChrootDaemon
            fi
        else
            if(whiptail --title "Warnning" --yesno "Chroot daemon already runngin.Restart?
chroot後台運行環境已經運行，需要重啓嗎？
                " --defaultno 10 60)then
                chrootReDaemon
                checkChrootDaemon
            else
                chRoot
            fi
        fi
        chRoot
    }
    configChroot(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config chroot & docker etc:" 25 60 15 \
            "a" "Config base schroot." \
            "b" "Docker in alpine" \
            "c" "Portainer in alpine" \
            "d" "Change chroot path" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置chroot環境和docker等:" 25 60 15 \
            "a" "配置基本的chroot環境（schroot 默認爲alpine)。" \
            "b" "Docker（alpine）。" \
            "c" "Docker配置界面（portainer in alpine）。" \
            "d" "遷移chroot目錄到其他路徑。" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                setChroot
                ;;
            b )
                docker
                #whiptail --title "Warnning" --msgbox "Not supported." 10 60
                chroot
                ;;
            c )
                dockerWeb
                chRoot
                ;;
            d )
                mvChrootp
            esac
        else
            chRoot
        fi
    }
    mvChrootp(){
        if (whiptail --title "Yes/No" --yesno "Continue?
是否繼續?" --defaultno 10 60)then
            checkSchroot
            chrootpNew=$(whiptail --title "Choose a path" --inputbox "
Current Path:
当前路径：
$(echo $chrootp)
---------------------------------
Input new chroot path:
請輸入遷移的新路徑：" 20 60 \
"" \
        3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                while [ true ]
                do
                    if [ ! -d $chrootpNew ];then
                        whiptail --title "Warnning" --msgbox "Path not found.
沒有檢測到路徑，請重新輸入" 10 60
                        mvChrootp
                    else
                        break
                    fi
                done
                chrootpNew=${chrootpNew%/}"/alpine"
                echo $chrootpNew > /etc/schroot/chrootp
                for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
                if [ -d "$chrootp/sys/fs/cgroup" ];then
                    mount --make-rslave $chrootp/sys/fs/cgroup
                    umount -R $chrootp/sys/fs/cgroup
                fi
                killall portainer
                killall dockerd
                rsync -a -r -v $chrootp"/" $chrootpNew
                sync
                sync
                sleep 3
                rm -rf $chrootp
                sed -i 's#'$chrootp'#'$chrootpNew'#g' /etc/schroot/chroot.d/alpine.conf
                whiptail --title "Success" --msgbox "Done.
    遷移成功" 10 60
                checkChrootDaemon
            else
                configChroot
            fi
        else
            chRoot
        fi
    }
    delChroot(){
        if (whiptail --title "Yes/No" --yesno "Continue?
是否繼續?" --defaultno 10 60)then
            checkSchroot
            for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
            apt-get -y autoremove schroot debootstrap
            if [ -d "$chrootp/sys/fs/cgroup" ];then
                mount --make-rslave $chrootp/sys/fs/cgroup
                umount -R $chrootp/sys/fs/cgroup
            fi
            killall portainer
            killall dockerd
            rm -rf $chrootp
            whiptail --title "Success" --msgbox "Done.
    删除成功" 10 60
        else
            chRoot
        fi
    }
    #--base-funcs-end--
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config chroot & docker etc:" 25 60 15 \
    "a" "Install & config base schroot." \
    "b" "Enter chroot." \
    "c" "Chroot daemon manager" \
    "d" "Remove all chroot." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置chroot環境和docker等:" 25 60 15 \
    "a" "安裝配置基本的chroot環境（schroot 默認爲alpine)。" \
    "b" "進入chroot。" \
    "c" "Chroot後台管理。" \
    "d" "徹底删除chroot。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        configChroot
        ;;
    b )
        enterChroot
        ;;
    c )
        checkChrootDaemon
        ;;
    d )
        delChroot
esac
else
    main
fi

}

#--qm set <ide,scsi,sata> disk
chQmdisk(){
    clear
    confDisk(){
        list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
        echo -n "">lsvm
        ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}'>>lsvm;done`
        ls=`cat lsvm`
        rm lsvm
        h=`echo $ls|wc -l`
        let h=$h*1
        if [ $h -lt 30 ];then
            h=30
        fi
        list1=`echo $list|awk 'NR>1{print $1}'`
        vmid=$(whiptail  --title " PveTools   Version : 2.2.5 " --menu "
Choose vmid to set disk:
選擇需要配置硬盤的vm：" 20 60 10 \
        $(echo $ls) \
        3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
你選的是：$vmid ，是否繼續?
                " 10 60)then
                while [ true ]
                do
                    if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                        whiptail --title "Warnning" --msgbox "
輸入格式錯誤，請重新輸入：
                        " 10 60
                        chQmdisk
                    else
                        break
                    fi
                done
                if [ $1 = 'add' ];then
                    #disks=`ls -alh /dev/disk/by-id|awk '{print $11" "$9" OFF"}'|awk -F "/" '{print $3}'|sed '/^$/d'|sed '/wwn/d'|sed '/^dm/d'|sed '/lvm/d'`
                    #added=`cat /etc/pve/qemu-server/$vmid.conf|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2$3"\r\n"}'`
                    disks=`ls -alh /dev/disk/by-id|sed '/\.$/d'|sed '/^$/d'|awk 'NR>1{print $9" "$11" OFF"}'|sed 's/\.\.\///g'|sed '/wwn/d'|sed '/^dm/d'|sed '/lvm/d'|sed '/nvme-nvme/d'`
                    d=$(whiptail --title " PveTools Version : 2.2.5 " --checklist "
disk list:
已添加的硬盤:
$(cat /etc/pve/qemu-server/$vmid.conf|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2" "$3}')
-----------------------
Choose disk:
選擇硬盤：" 30 90 10 \
                    $(echo $disks) \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    t=$(whiptail --title " PveTools Version : 2.2.5 " --menu "
Choose disk type:
選擇硬盤接口類型：" 20 60 10 \
                    "sata" "vm sata type" \
                    "scsi" "vm scsi type" \
                    "ide" "vm ide type" \
                    3>&1 1>&2 2>&3)
                    exits=$?
                    if [ $exitstatus = 0 ] && [ $exits = 0 ]; then
                        did=`qm config $vmid|sed -n '/^'$t'/p'|awk -F ':' '{print $1}'|sort -u -r|grep '[0-9]*$' -o|awk 'NR==1{print $0}'`
                        if [ $did ];then
                            did=$((did+1))
                        else
                            did=0
                        fi
                        #d=`ls -alh /dev/disk/by-id|grep $d|awk 'NR==1{print $9}'`
                        d=`echo $d|sed 's/\"//g'`
                        for i in $d
                        do
                            if [ `cat /etc/pve/qemu-server/$vmid.conf|grep $i|wc -l` = 0 ];then
                                #if [ $t = "ide" ] && [ `echo $i|grep "nvme"|wc -l` -gt 0 ];then
                                if [ $t = "ide" ] && [ $did -gt 3 ];then
                                    whiptail --title "Warnning" --msgbox "ide is greate then 3.
ide的類型已經超過3個,請重選其他類型!" 10 60
                                else
                                    qm set $vmid --$t$did /dev/disk/by-id/$i
                                fi
                                sleep 1
                                did=$((did+1))
                            fi
                        done
                        whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                        chQmdisk
                    else
                        chQmdisk
                    fi
                fi
                if [ $1 = 'rm' ];then
                    disks=`qm config $vmid|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2$3" OFF"}'`
                    d=$(whiptail --title " PveTools Version : 2.2.5 " --checklist "
Choose disk:
選擇硬盤：" 20 90 10 \
                    $(echo $disks) \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in $d
                        do
                            i=`echo $i|sed 's/\"//g'`
                            qm set $vmid --delete $i
                        done
                        whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                        chQmdisk
                    else
                        chQmdisk
                    fi
                fi
            else
                chQmdisk
            fi
        fi

    }
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Config qm set disks:" 25 60 15 \
        "a" "set disk to vm." \
        "b" "unset disk to vm." \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "配置qm set 物理硬盤給虛拟機:" 25 60 15 \
        "a" "添加硬盤給虛拟機。" \
        "b" "删除虛拟機裏的硬盤。" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            clear
            confDisk add
            ;;
        b )
            clear
            confDisk rm
        esac
    fi
}


manyTools(){
    clear
    nMap(){
        clear
        if [ ! -f "/usr/bin/nmap" ];then
            apt-get install nmap -y
        fi
        map=$(whiptail --title "nmap tools." --inputbox "
Input the Ip address.(192.168.1.0/24)
輸入局域網ip地址段。（例子：192.168.1.0/24)
        " 10 60 \
        "" \
        3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ true ]
            do
                if [ ! `echo $map|grep "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*$"` ];then
                    whiptail --title "Warnning" --msgbox "
Wrong format!!!   input again:
格式不對！！！請重新輸入：
                    " 10 60
                    nMap
                else
                    break
                fi
            done
            maps=`nmap -sP $map`
            whiptail --title "nmap tools." --msgbox "
$maps
            " --scrolltext 30 60
        else
            manyTools
        fi
    }
    setDns(){
        clear
        dname=`cat /etc/resolv.conf|grep 'nameserver'`
        if [ `cat /etc/resolv.conf|grep 'nameserver'|wc -l` != 0 ];then
            if [ $L = "en" ];then
                d=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "DNS - Many Tools:
Detect exist nameserver,Please choose:
                " 25 60 15 \
                "a" "Add nameserver." \
                "b" "Replace nameserver." \
                3>&1 1>&2 2>&3)
            else
                d=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "DNS - 常用的工具:
檢測到已經配置有dns服務器: \
$(for i in $dname;do echo $i ;done)  \
------------------------------ \
請選擇以下操作：
                " 25 60 15 \
                "a" "添加dns." \
                "b" "替換dns." \
                3>&1 1>&2 2>&3)
            fi
            exitstatus=$?
            if [ $exitstatus != 0 ]; then
                manyTools
            fi
        fi
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "DNS - Many Tools:" 25 60 15 \
            "a" "8.8.8.8(google)." \
            "b" "223.5.5.5(alidns)." \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "DNS - 常用的工具:" 25 60 15 \
            "a" "8.8.8.8(谷歌)." \
            "b" "223.5.5.5(阿裏)." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                dn="8.8.8.8"
                case "$d" in
                    b )
                        echo "nameserver    8.8.8.8" > /etc/resolv.conf
                esac
                echo "nameserver    8.8.8.8" >> /etc/resolv.conf
                ;;
            b )
                dn="223.5.5.5"
                case "$d" in
                    b )
                        echo "nameserver    223.5.5.5" > /etc/resolv.conf
                esac
                echo "nameserver    223.5.5.5" >> /etc/resolv.conf
                ;;
            esac
            if [ `cat /etc/resolv.conf | grep ${dn}|wc -l` != 0 ];then
                whiptail --title "Success" --msgbox "Done.
配置完成。"  10 60
                manyTools
            else
                whiptail --title "Warnning" --msgbox "Unsuccess.Please retry.
配置未成功。請重試。"  10 60
                setDns
            fi
        else
            manyTools
        fi
    }
    freeMemory(){
        clear
        if(whiptail --title "Free memory" --yesno "Free memory?
釋放内存？" 10 60 );then
            sync
            sync
            sync
            echo 3 > /proc/sys/vm/drop_caches
            echo 0 > /proc/sys/vm/drop_caches
            whiptail --title "Success" --msgbox "Done." 10 60
        else
            manyTools
        fi
    }
    speedTest(){
        op=`pwd`
        cd ~
        git clone https://github.com/sivel/speedtest-cli.git
        chmod +x ~/speedtest-cli/speedtest.py
        python ~/speedtest-cli/speedtest.py
        echo "Enter to continue."
        cd $op
        read x
    }
    bbr(){
        op=`pwd`
        if [ ! -d "/opt/bbr" ];then
            mkdir /opt/bbr
        fi
        cp ./plugins/tcp.sh /opt/bbr
        cd /opt/bbr
        ./tcp.sh
        cd $op
    }
    v2ray(){
        op=`pwd`
        cd ~
        git clone https://github.com/ivanhao/ivan-v2ray
        chmod +x ~/ivan-v2ray/install.sh
        ~/ivan-v2ray/install.sh
        echo "Enter to continue."
        cd $op
        read x
    }
    vbios(){
        echo "..."
        if(whiptail --title "vbios tools" --yesno "get vbios?
提取顯卡？" 10 60 );then
            cd ..
            git clone https://github.com/ivanhao/envytools
            cd envytools
            apt-get install cmake flex libpciaccess-dev bison libx11-dev libxext-dev libxml2-dev libvdpau-dev python3-dev cython3 pkg-config
            cmake .
            make
            make install
            nvagetbios -s prom > vbios.bin
            cd ..
            git clone https://github.com/awilliam/rom-parser
            cd rom-parser
            make
            ./rom-parser ../envytools/vbios.bin
            sleep 5
            if [ `rom-parser ../envytools/vbios.bin|grep Error|wc -l` = 0 ];then
                cp ../envytools/vbios.bin /usr/share/kvm/
                whiptail --title "Success" --msgbox "Done.see vbios in '/usr/share/kvm/vbios.bin'
提取顯卡vbios成功，文件在'/usr/share/kvm/vbios.bin',可以直接在配置文件中添加romfile=vbios.bin" 10 60
            else
                whiptail --title "Warnning" --msgbox "Room parse error.
提取顯卡vbios失敗。" 10 60
            fi

        fi
        manyTools

    }
    folder2ram(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "folder2ram:" 25 60 15 \
            "a" "install" \
            "b" "Uninstall" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "USB設備做爲系統盤的優化:" 25 60 15 \
            "a" "安裝。" \
            "b" "卸載。" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                if(whiptail --title "vbios tools" --yesno "install folder2ram to optimaz USB OS storage?
        安裝USB設備做爲系統盤的優化？" 10 60 );then
                    wget https://raw.githubusercontent.com/ivanhao/pve-folder2ram/master/install.sh -O -| bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            b )
                if(whiptail --title "vbios tools" --yesno "uninstall folder2ram optimaz?
        卸載USB設備做系統盤的優化？" 10 60 );then
                    wget https://raw.githubusercontent.com/ivanhao/pve-folder2ram/master/uninstall.sh -O -| bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            esac
        fi
        manyTools
    }


    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Many Tools:" 25 60 15 \
        "a" "Local network scans(nmap)." \
        "b" "Set DNS." \
        "c" "Free Memory." \
        "d" "net speedtest" \
        "e" "bbr\\bbr+" \
        "f" "config v2ray" \
        "g" "Nvida Video Card vbios" \
        "h" "folder2ram" \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "常用的工具:" 25 60 15 \
        "a" "局域網掃描。" \
        "b" "配置DNS。" \
        "c" "釋放内存。" \
        "d" "speedtest測速" \
        "e" "安裝bbr\\bbr+" \
        "f" "配置v2ray" \
        "g" "顯(N)卡vbios提取" \
        "h" "USB設備做爲系統盤的優化" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            nMap
            ;;
        b )
            setDns
            ;;
        c )
            freeMemory
            ;;
        d )
            speedTest
            ;;
        e )
            bbr
            ;;
        f )
            v2ray
            ;;
        g )
            vbios
            ;;
        h|H )
            folder2ram
            ;;
        esac
    fi

}
chNFS(){
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "NFS:" 25 60 15 \
        "a" "Install nfs server." \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "NFS:" 25 60 15 \
        "a" "安裝NFS服務器。" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            if(whiptail --title "Yes/No" --yesno "Comfirm?
是否安裝？" 10 60)then
                apt-get install nfs-kernel-server
                whiptail --title "OK" --msgbox "Complete.If you use zfs use 'zfs set sharenfs=on <zpool> to enable NFS.'
安裝配置完成。如果你使用zfs，執行'zfs set sharenfs=on <zpool>來開啓NFS。" 10 60
            else
                chNFS
            fi
            ;;
        esac
    fi


}
sambaOrNfs(){
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Samba or NFS:" 25 60 15 \
        "a" "samba." \
        "b" "NFS" \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "Samba or NFS:" 25 60 15 \
        "a" "samba." \
        "b" "NFS" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            chSamba
            ;;
        b )
            chNFS
        esac
    fi


}

omvInPve(){
    if(whiptail --title "Yes/No" --yesno "Install omv in proxmox ve directlly?
将要在proxmox ve中直接安裝omv,請确認是否繼續：" 10 60);then
        if [ -f "/usr/sbin/omv-engined" ];then
            if(whiptail --title "Yes/No" --yesno "Already installed omv in proxmox ve.Reinstall?
已經檢測到安裝了omv,請确認是否重裝？" 10 60);then
                echo "reinstalling..."
            else
                main
            fi
        fi
        apt-get -y install git
        cd ~
        git clone https://github.com/ivanhao/omvinpve
        cd omvinpve
        ./OmvInPve.sh
        main
    else
        main
    fi
}



ConfBackInstall(){
    path(){
x=$(whiptail --title "config path" --inputbox "Input backup path:
輸入備份路徑:" 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];then
    if [ ! -d $x ];then
        whiptail --title "Warnning" --msgbox "Path not found." 10 60
        path
    fi
else
    main
fi
    }
    count(){
y=$(whiptail --title "config backup number" --inputbox "Input backup last number:
輸入保留備份數量:" 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];then
    if [ ! `echo $y|grep '^[0-9]$'` ];then
        whiptail --title "warnning" --msgbox "Invalid content,retry!" 10 60
        count
    fi
else
    main
fi
    }
    path
    count
    x=$x'/pveConfBackup'
    if [ ! -d $x ];then
        mkdir $x
    fi
    if [ ! -d $x/`date '+%Y%m%d'` ];then
        mkdir $x/`date '+%Y%m%d'`
    fi
    cp -rf /etc/pve/qemu-server/* $x/`date '+%Y%m%d'`/
    d=`ls -l $x|awk 'NR>1{print $9}'|wc -l`
    while [ $d -gt $y ]
    do
        rm -rf $x'/'`ls -l $x|awk 'NR>1{print $9}'|head -n 1`
        d=`ls -l $x|awk 'NR>1{print $9}'|wc -l`
    done
    cat << EOF > /usr/bin/pveConfBackup
#!/bin/bash
x='$x'
y=$y
if [ ! -d $x/`date '+%Y%m%d'` ];then
    mkdir $x/`date '+%Y%m%d'`
fi
cp -r /etc/pve/qemu-server/* $x/\`date '+%Y%m%d'\`/
d=\`ls -l $x|awk 'NR>1{print \$9}'|wc -l\`
while [ \$d -gt \$y ]
do
    rm -rf $x/\`ls -l $x|awk 'NR>1{print \$9}'|head -n 1\`
    d=\`ls -l $x|awk 'NR>1{print \$9}'|wc -l\`
done
EOF
    chmod +x /usr/bin/pveConfBackup
    sed -i '/pveConfBackup/d' /etc/crontab
    echo "0  0  *  *  *  root  /usr/bin/pveConfBackup" >> /etc/crontab
    systemctl restart cron
    whiptail --title "success" --msgbox "Install complete." 10 60
    main
}
ConfBackUninstall(){
    if [ `cat /etc/crontab|grep pveConfBackup|wc -l` -gt 0 ];then
        sed -i '/pveConfBackup/d' /etc/crontab
        rm -rf /usr/bin/pveConfBackup
        whiptail --title "success" --msgbox "Uninstall complete." 10 60
    else
        whiptail --title "warnning" --msgbox "No installration found." 10 60
    fi
    main
}
ConfBack(){
OPTION=$(whiptail --title " pve vm config backup " --menu "
auto backup /etc/pve/qemu-server path's conf files.
自動備份/etc/pve/qemu-server路徑下的conf文件
Select: " 25 60 15 \
    "a" "Install. 安裝" \
    "b" "Uninstall. 卸載" \
3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
a | A )
        ConfBackInstall
        ;;
b | B)
        ConfBackUninstall
        ;;
* )
        ConfBack
    esac
fi
}
#----------------------functions--end------------------#


#--------------------------function-main-------------------------#
#    "a" "無腦模式" \
          #  a )
          #      if (whiptail --title "Test Yes/No Box" --yesno "Choose between Yes and No." 10 60) then
          #          whiptail --title "OK" --msgbox "OK" 10 60
          #      else
          #          whiptail --title "OK" --msgbox "OK" 10 60
          #      fi
          #      sleep 3
          #      main
          #      ;;
          #  b )
          #      echo "b"
          #      ;;
          #  c )
          #      echo "c"
          #      ;;

main(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "
Github: https://github.com/ivanhao/pvetools
Please choose:" 25 60 15 \
    "b" "Config apt source(change to ustc.edu.cn and so on)." \
    "c" "Install & config samba or NFS." \
    "d" "Install mailutils and config root email." \
    "e" "Config zfs_arc_max & Install zfs-zed." \
    "f" "Install & config VIM." \
    "g" "Install cpufrequtils to save power." \
    "h" "Config hard disks to spindown." \
    "i" "Config PCI hardware pass-thrugh." \
    "j" "Config web interface to display sensors data." \
    "k" "Config enable Nested virtualization." \
    "l" "Remove subscribe notice." \
    "m" "Config chroot & docker etc." \
    "n" "Many tools." \
    "p" "Auto backup vm conf file." \
    "u" "Upgrade this script to new version." \
    "L" "Change Language." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.2.5 " --menu "
Github: https://github.com/ivanhao/pvetools
請選擇相應的配置：" 25 60 15 \
    "b" "配置apt國内源(更換爲ustc.edu.cn,去除企業源等)" \
    "c" "安裝配置samba或NFS" \
    "d" "安裝配置root郵件通知" \
    "e" "安裝配置zfs最大内存及zed通知" \
    "f" "安裝配置VIM" \
    "g" "安裝配置CPU省電" \
    "h" "安裝配置硬盤休眠" \
    "i" "配置PCI硬件直通" \
    "j" "配置pve的web界面顯示傳感器溫度" \
    "k" "配置開啓嵌套虛拟化" \
    "l" "去除訂閱提示" \
    "m" "配置chroot環境和docker等" \
    "n" "常用的工具" \
    "p" "自動備份虛拟機conf文件" \
    "u" "升級該pvetools腳本到最新版本" \
    "L" "Change Language" \
    3>&1 1>&2 2>&3)
fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$OPTION" in
        a )
            echo "Not support!Please choose other options."
            echo "本版本已不支持無腦更新，請選擇具體項目進行操作！"
            sleep 3
            main
            chSource wn
            chSamba wn
            chMail wn
        #    chZfs wn
            chVim wn
        #    chCpu wn
            chSpindown wn
            chNestedV wn
            chSubs wn
            chSensors wn
            echo "Config complete!Back to main menu 5s later."
            echo "已經完成配置！5秒後返回主界面。"
            echo "5"
            sleep 1
            echo "4"
            sleep 1
            echo "3"
            sleep 1
            echo "2"
            sleep 1
            echo "1"
            sleep 1
            main
            ;;
        b )
            chSource
            main
            ;;
        c )
            sambaOrNfs
            main
            ;;
        d )
            chMail
            main
            ;;
        e )
            chZfs
            main
            ;;
        f )
            chVim
            main
            ;;
        g )
            chCpu
            main
            ;;
        h )
            chSpindown
            main
            ;;
        i )
            #echo "not support yet."
            chPassth
            main
            ;;
        j )
            chSensors
            sleep 2
            main
            ;;
        k )
            clear
            chNestedV
            main
            ;;
        l )
            chSubs
            main
            ;;
        m )
            chRoot
            main
            ;;
        n )
            manyTools
            main
            ;;
        o )
            omvInPve
            ;;
        p )
            ConfBack
            ;;
        u )
            git pull
            echo "Now go to main interface:"
            echo "即将回主界面。。。"
            echo "3"
            sleep 1
            echo "2"
            sleep 1
            echo "1"
            sleep 1
            ./pvetools.sh
            ;;
        L )
            if (whiptail --title "Yes/No Box" --yesno "Change Language?
修改語言？" 10 60);then
                if [ $L = "zh" ];then
                    L="en"
                else
                    L="zh"
                fi
                main
                #main $L
            fi
            ;;
        exit | quit | q )
            exit
            ;;
        esac
    else
        exit
    fi
}
#----------------------functions--end------------------#
#if [ `export|grep "zh_CN"|wc -l` = 0 ];then
#    L="en"
#else
#    L="zh"
#fi
#--------santa-start--------------
DrawTriangle() {
	a=$1
	color=$[RANDOM%7+31]
	if [ "$a" -lt "8" ] ;then
		b=`printf "%-${a}s\n" "0" |sed 's/\s/0/g'`
		c=`echo "(31-$a)/2"|bc`
        d=`printf "%-${c}s\n"`
		echo "${d}`echo -e "\033[1;5;${color}m$b\033[0m"`"
	elif [ "$a" -ge "8" -a "$a" -le "21" ] ;then
		e=$[a-8]
		b=`printf "%-${e}s\n" "0" |sed 's/\s/0/g'`
		c=`echo "(31-$e)/2"|bc`
		d=`printf "%-${c}s\n"`
		echo "${d}`echo -e "\033[1;5;${color}m$b\033[0m"`"
	fi
}
DrawTree() {
	e=$1
	b=`printf "%-3s\n" "|" | sed 's/\s/|/g'`
	c=`echo "($e-3)/2"|bc`
	d=`printf "%-${c}s\n" " "`
	echo -e "${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}"
    echo "       Merry Cristamas!"
}
Display(){
	for i in `seq 1 2 31`; do
		[ "$i"="21" ] && DrawTriangle $i
		if [ "$i" -eq "31" ];then
			DrawTree $i
		fi
	done
}
if [[ `date +%m%d` = 1224  ||  `date +%m%d` = 1225 ]] && [ ! -f '/tmp/santa' ];then
    for i in {1..6}
    do
        Display
        sleep 1
        clear
    done
    touch /tmp/santa
fi

#--------santa-end--------------
if (whiptail --title "Language" --yes-button "中文" --no-button "English"  --yesno "Choose Language:
選擇語言：" 10 60) then
    L="zh"
else
    L="en"
fi
main
