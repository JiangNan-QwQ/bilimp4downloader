#!/bin/bash
#江南_XnLr
download() {
    local url=$1
    while true
    do
        echo "===============开始下载文件==============="
        if [ -n "$cookie_path" ]; then
            output_path=$(yt-dlp -f "bestvideo*+bestaudio/best" --cookies "$cookie_path" --print after_move:filename -q "$url")
        else
            output_path=$(yt-dlp -f "bestvideo*+bestaudio/best" --print after_move:filename -q "$url")
        fi

        echo "下载完成！文件保存为：$output_path"
        # 添加退出循环，避免无限重复下载
        read -p "是否继续下载其他视频? (y/n): " continue_download
        if [ "$continue_download" != "y" ] && [ "$continue_download" != "Y" ]; then
            break
        fi
        read -p "输入新的视频链接(带协议，或按回车退出)： " new_url
        if [ -z "$new_url" ]; then
            break
        fi
        url="$new_url"
    done
}

# 检测是否在Termux环境中
if [ -d "/data/data/com.termux/files" ]; then
    echo "检测到Termux环境"
    # 更新Termux包管理器
    pkg update -y && pkg upgrade -y
    # 安装必要的依赖
    pkg install -y python ffmpeg
    pip install yt-dlp
else
    # 普通Linux环境
    apt update && apt upgrade -y
    apt install -y python3 python3-pip ffmpeg
    pip3 install yt-dlp
fi

while true
do
    read -p "输入保存路径 (当前目录: $PWD/): " path
    if [ -z "$path" ]; then
        path="."
        break
    fi
    
    full_path="$PWD/$path"
    if [ -f "$full_path" ]; then
        echo "错误：路径是一个文件，请输入目录路径！"
    elif [ -d "$full_path" ]; then
        break
    else
        # 如果目录不存在，询问是否创建
        read -p "目录不存在，是否创建? (y/n): " create_dir
        if [ "$create_dir" = "y" ] || [ "$create_dir" = "Y" ]; then
            mkdir -p "$full_path"
            if [ $? -eq 0 ]; then
                break
            else
                echo "创建目录失败！"
            fi
        else
            echo "请输入正确路径！"
        fi
    fi
done

cookie_path=""
while true
do
    read -p "输入Netscape形式后缀为.txt的cookie文件路径(不需要请直接回车) $PWD/: " cookie
    if [ -z "$cookie" ]; then
        break
    fi
    
    full_cookie_path="$PWD/$cookie"
    if [ -f "$full_cookie_path" ]; then
        cookie_path="$full_cookie_path"
        break
    elif [ -d "$full_cookie_path" ]; then
        echo "错误：这是一个目录，请输入文件路径！"
    else
        echo "文件不存在，请输入正确路径！"
    fi
done

cd "$path"
read -p "输入视频链接(带协议)： " durl

if [ -z "$durl" ]; then
    echo "错误：视频链接不能为空！"
    exit 1
fi

download "$durl"