#!/bin/bash

# 本项目为开源项目；开发支持：搜码(souma.net) 速拓云(sutuoc.com)；使用GPL-3.0开源许可协议

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 获取所有网络接口名称
interfaces=$(ip -o link show | awk -F': ' '{print $2}')

echo -e "${BLUE}=== 网络接口列表 ===${NC}"
echo "$interfaces"
echo -e "\n${BLUE}=== IP 地址详情 ===${NC}"

# 遍历每个接口并提取 IPv4/IPv6
for intf in $interfaces; do
  # 跳过回环接口 (lo)
  if [ "$intf" = "lo" ]; then
    continue
  fi

  # 提取 IPv4 地址 (inet)
  ipv4=$(ip addr show $intf | grep -w 'inet' | awk '{print $2}' | xargs)
  # 提取 IPv6 地址 (inet6，排除本地链路地址 fe80::)
  ipv6=$(ip addr show $intf | grep -w 'inet6' | grep -v 'fe80::' | awk '{print $2}' | xargs)

  # 仅在有IP时输出
  if [ -n "$ipv4" ] || [ -n "$ipv6" ]; then
    echo -e "${GREEN}接口: $intf${NC}"
    [ -n "$ipv4" ] && echo -e "  ${YELLOW}IPv4: $ipv4${NC}"
    [ -n "$ipv6" ] && echo -e "  ${BLUE}IPv6: $ipv6${NC}"
  fi
done