#!/bin/bash

#本项目为开源项目；开发支持：搜码(souma.net) ；速拓云(sutuoc.com)；使用GPL-3.0开源许可协议

# 强制以root权限运行
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
    exit $?
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 全局变量
server_ip=$(hostname -I | awk '{print $1}')
uptime_cn=$(uptime -p | sed 's/up/已运行/; s/hour/时/; s/minutes/分/; s/days/天/; s/months/月/')

# 主菜单
show_main_menu() {
    clear
    echo -e "${GREEN}===================================${NC}"
    echo -e "${BLUE}        Linux 工具箱 v1.0内测${NC}"
    echo -e "${GREEN}===================================${NC}"
    echo -e "开发支持：搜码(souma.net) 速拓云(sutuoc.com)"
    echo -e "${GREEN}-----------------------------------${NC}"
    echo -e "${YELLOW}服务器IP: ${GREEN}$server_ip${NC}"
    echo -e "${YELLOW}运行时间: ${GREEN}$uptime_cn${NC}"
    echo -e "${GREEN}-----------------------------------${NC}"
    echo -e "1. 系统管理菜单"
    echo -e "2. 磁盘管理菜单"
    echo -e "3. 软件管理菜单"
    echo -e "4. 退出工具箱"
    echo -e "${GREEN}===================================${NC}"
}

# 系统管理菜单
show_system_menu() {
    clear
    echo -e "${GREEN}===================================${NC}"
    echo -e "${BLUE}         系统管理菜单${NC}"
    echo -e "${GREEN}===================================${NC}"
    echo -e "1. 重启服务器"
    echo -e "2. 修改用户密码"
    echo -e "3. 修改SSH端口"
    echo -e "4. 同步上海时间"
    echo -e "5. 返回主菜单"
    echo -e "${GREEN}===================================${NC}"
}

# 磁盘管理菜单
show_disk_menu() {
    clear
    echo -e "${GREEN}===================================${NC}"
    echo -e "${BLUE}         磁盘管理菜单${NC}"
    echo -e "${GREEN}===================================${NC}"
    echo -e "1. 挂载数据盘"
    echo -e "2. 卸载数据盘"
    echo -e "3. 查看磁盘信息"
    echo -e "4. 返回主菜单"
    echo -e "${GREEN}===================================${NC}"
}

# 软件管理菜单
show_software_menu() {
    clear
    echo -e "${GREEN}===================================${NC}"
    echo -e "${BLUE}         软件管理菜单${NC}"
    echo -e "${GREEN}===================================${NC}"
    echo -e "1. 更新YUM源"
    echo -e "2. 安装宝塔面板"
    echo -e "3. 返回主菜单"
    echo -e "${GREEN}===================================${NC}"
}

# 挂载数据盘
mount_data_disk() {
    read -p "请输入数据盘设备名 [默认：/dev/vdb1]: " disk_device
    disk_device=${disk_device:-"/dev/vdb1"}

    read -p "请输入挂载点目录 [推荐：/data]: " mount_point
    mount_point=${mount_point:-"/data"}

    # 检查挂载点目录是否存在，不存在则创建
    if [ ! -d "$mount_point" ]; then
        sudo mkdir -p "$mount_point"
    fi

    # 检查数据盘是否已经被挂载
    if grep -qs "$disk_device " /proc/mounts; then
        echo "数据盘 $disk_device 已经被挂载"
        return
    fi

    # 检查数据盘是否存在并且为块设备
    if [ ! -b "$disk_device" ]; then
        echo "数据盘 $disk_device 不存在或者不是块设备"
        return
    fi

    # 格式化数据盘（这里假设为ext4，用户可以根据需要修改）
    # 注意：格式化会删除数据盘上的所有数据，请谨慎操作
    # read -p "数据盘 $disk_device 尚未格式化，是否格式化？(y/n): " format_choice
    # if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
    #     sudo mkfs.ext4 "$disk_device"
    # else
    #     echo "取消格式化，退出挂载。"
    #     return
    # fi

    # 挂载数据盘
    sudo mount "$disk_device" "$mount_point"
    echo "数据盘 $disk_device 成功挂载到 $mount_point"

    # 将数据盘添加到 /etc/fstab 实现开机自动挂载
    # 注意：这里假设文件系统类型为ext4，用户需要根据实际情况修改
    echo "$disk_device $mount_point ext4 defaults 0 2" | sudo tee -a /etc/fstab
    echo "数据盘已成功挂载到 $mount_point，并已设置为开机自动挂载。"
}

# 卸载数据盘
unmount_data_disk() {
    read -p "请输入数据盘设备名 [默认：/dev/vdb1]: " disk_device
    disk_device=${disk_device:-"/dev/vdb1"}

    read -p "请输入挂载点目录 [默认：/data]: " mount_point
    mount_point=${mount_point:-"/data"}

    # 检查挂载点目录是否存在
    if [ ! -d "$mount_point" ]; then
        echo "挂载点目录 $mount_point 不存在"
        return
    fi

    # 检查数据盘是否已经被挂载
    if ! grep -qs "$disk_device" /proc/mounts; then
        echo "数据盘 $disk_device 没有被挂载"
        return
    fi

    # 卸载数据盘
    sudo umount "$mount_point"
    echo "数据盘 $disk_device 成功从 $mount_point 卸载"

    # 从 /etc/fstab 中移除自动挂载条目
    sudo sed -i "/$disk_device/d" /etc/fstab
    echo "数据盘 $disk_device 已从 /etc/fstab 中移除，不会开机自动挂载。"
}

# 系统管理功能
handle_system_menu() {
    while true; do
        show_system_menu
        read -p "请选择操作 [1-5]: " choice
        case $choice in
            1) 
                echo -e "${RED}正在重启服务器...${NC}"
                reboot
                ;;
            2)
                read -p "输入用户名: " username
                if id "$username" &>/dev/null; then
                    passwd $username
                else
                    echo -e "${RED}用户不存在！${NC}"
                fi
                ;;
            3)
                read -p "输入新SSH端口 (1024-65535): " port
                if [[ $port =~ ^[0-9]+$ ]] && [ $port -ge 1024 ] && [ $port -le 65535 ]; then
                    sed -i "s/^#Port.*/Port $port/" /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${GREEN}SSH端口已修改为 $port${NC}"
                else
                    echo -e "${RED}无效端口号！${NC}"
                fi
                ;;
            4)
                timedatectl set-timezone Asia/Shanghai
                systemctl restart systemd-timesyncd
                echo -e "${GREEN}当前时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
                ;;
            5) return ;;
            *) echo -e "${RED}无效选择！${NC}" ;;
        esac
        read -p "按回车继续..."
    done
}

# 主程序循环
while true; do
    show_main_menu
    read -p "请输入选项 [1-4]: " main_choice
    
    case $main_choice in
        1) handle_system_menu ;;
        2)
            while true; do
                show_disk_menu
                read -p "请选择操作 [1-4]: " disk_choice
                case $disk_choice in
                    1) mount_data_disk ;;
                    2) unmount_data_disk ;;
                    3) 
                        echo -e "${GREEN}磁盘使用情况：${NC}"
                        df -h
                        echo -e "\n${GREEN}物理磁盘列表：${NC}"
                        lsblk -d -o NAME,SIZE,MODEL,MOUNTPOINT
                        ;;
                    4) break ;;
                    *) echo -e "${RED}无效选择！${NC}" ;;
                esac
                read -p "按回车继续..."
            done
            ;;
        3)
            while true; do
                show_software_menu
                read -p "请选择操作 [1-3]: " soft_choice
                case $soft_choice in
                    1) 
                        echo -e "${YELLOW}正在优化YUM源...${NC}"
                        bash <(curl -sSL https://linuxmirrors.cn/main.sh)
                        ;;
                    2)
                        echo -e "${YELLOW}正在安装宝塔面板...${NC}"
                        curl -sSO https://download.bt.cn/install/install_panel.sh
                        bash install_panel.sh 19e49bd8
                        ;;
                    3) break ;;
                    *) echo -e "${RED}无效选择！${NC}" ;;
                esac
                read -p "按回车继续..."
            done
            ;;
        4)
            echo -e "${GREEN}感谢使用，再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项，请重新输入！${NC}"
            sleep 1
            ;;
    esac
done