#!/bin/bash

echo_with_timestamp() {
    local message=$1
    echo "[$(date '+%H:%M:%S')] $message"
}

function pause (){
    read -p "Press ENTER to continue"
}

echo "===================================="
echo "    ______  _______          _____           _       __"
sleep 0.2
echo "   / ____/ / ____( )_____   / ___/__________(_)___  / /_"
sleep 0.2
echo "  / __/   / /_   |// ___/   \__ \/ ___/ ___/ / __ \/ __/"
sleep 0.2
echo " / /____ / __/    (__  )   ___/ / /__/ /  / / /_/ / /_  "
sleep 0.2
echo "/_____(_)_/      /____/   /____/\___/_/  /_/ .___/\__/  "
sleep 0.2
echo "                                          /_/"
sleep 0.2
echo "------------------------------------"
echo "A Duplicate file Cleaner Script Made By Eternal_Future (https://002397.xyz)"
echo "Automatic Clean:bash <(curl -sSL https://raw.githubusercontent.com/Eternal-Future/scripts/main/dfc.sh)"
echo "Clean after Confirm:bash <(curl -sSL https://raw.githubusercontent.com/Eternal-Future/scripts/main/dfc2.sh)"
echo "This Script will run automatically after 5 seconds"
echo "Ctrl+C to Exit"
echo "===================================="
sleep 5
echo_with_timestamp "正在统计当前目录及子目录文件总数"

# 统计文件总数
total_files=$(find . -type f | wc -l | tr -d '[:space:]')
current_file=0

# 临时文件存放 MD5 值
temp_file=$(mktemp)
temp_file_md5=$(mktemp)

echo_with_timestamp "完成！总文件有： $total_files 个"
echo_with_timestamp "===================================="

# 进度条函数
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local progress_bar_width=50
    local progress=$((percent * progress_bar_width / 100))
    
    printf "\r[$(date '+%H:%M:%S')] ["
    for ((i=0; i<progress; i++)); do printf "#"; done
    for ((i=progress; i<progress_bar_width; i++)); do printf " "; done
    printf "] %d%% 当前文件数: %d, 文件总数: %d" "$percent" "$current" "$total"
}

echo_with_timestamp "正在计算当前目录及子目录所有文件MD5以查找重复文件并删除"
echo_with_timestamp "在进度条走完前，您的文件并不会作任何更改，可以随时按下Ctrl+C以退出"

# 递归计算所有文件的 MD5 并显示进度
find . -type f -print0 | while IFS= read -r -d '' file; do
    md5sum "$file" >> "$temp_file"
    current_file=$((current_file + 1))
    show_progress "$current_file" "$total_files"
done
echo 
echo_with_timestamp "===================================="
echo_with_timestamp "计算完成！结果如下"
echo_with_timestamp "若输出为空则没有重复文件！"
echo_with_timestamp "------------------------------------"

# 使用 awk 统计相同 MD5 的文件个数并输出文件名
awk '
BEGIN { FS = "  " }
{
    md5 = $1;
    file = $2;
    count[md5]++;
    files[md5] = files[md5] ? files[md5] ", " file : file;
}
END {
    for (md5 in count) {
        if (count[md5] > 1) {
            printf "文件MD5: %s, 数量: %d, 相关文件: %s\n", md5, count[md5], files[md5];
            # 仅保留第一个文件，其余文件标记删除
            split(files[md5], file_list, ", ");
            for (i = 2; i <= length(file_list); i++) {
                print file_list[i] >> "'"$temp_file_md5"'";
            }
        }
    }
}
' "$temp_file"

echo_with_timestamp "------------------------------------"
echo_with_timestamp "按下回车以清理重复文件 按下Ctrl+C以中止行动"
echo_with_timestamp "===================================="
pause
echo_with_timestamp "正在删除重复文件"
echo_with_timestamp "------------------------------------"

# 删除标记文件
while IFS= read -r file_to_delete; do
    echo_with_timestamp "删除: $file_to_delete"
    rm "$file_to_delete"
done < "$temp_file_md5"

# 删除临时文件
rm "$temp_file" "$temp_file_md5"

echo_with_timestamp "------------------------------------"
echo_with_timestamp "重复文件已删除。"
echo_with_timestamp "===================================="
