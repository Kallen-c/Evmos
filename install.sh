#!/bin/bash
echo -e "\033[35m"
echo -e "https://t.me/ro_cryptoo"
echo -e "https://t.me/whitelistx1000"

echo -ne "\033[35m██████╗░░█████╗░  "
echo -e "\033[34m░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░█████╗░"

echo -ne "\033[35m██╔══██╗██╔══██╗  "
echo -e "\033[34m██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔══██╗"

echo -ne "\033[35m██████╔╝██║░░██║  "
echo -e "\033[34m██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░██║░░██║"

echo -ne "\033[35m██╔══██╗██║░░██║  "
echo -e "\033[34m██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██║░░██║"

echo -ne "\033[35m██║░░██║╚█████╔╝  "
echo -e "\033[34m╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░╚█████╔╝"

echo -ne "\033[35m╚═╝░░╚═╝░╚════╝░  "
echo -e "\033[34m░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░░╚════╝░"

echo -e "\033[35m"

sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget -y &>/dev/null


if [ ! $EVMOS_NODENAME ]; then
	read -p "Enter node name: " EVMOS_NODENAME
fi
sleep 1
echo 'export EVMOS_NODENAME='$EVMOS_NODENAME >> $HOME/.profile
echo "Installing dependencies"
curl -s https://raw.githubusercontent.com/Kallen-c/utils/main/installers/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/Kallen-c/utils/main/installers/install_go.sh | bash &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Depedencies installed"
if [ ! -d $HOME/evmos/ ]; then
  git clone https://github.com/tharsis/evmos.git &>/dev/null
	cd $HOME/evmos
	git checkout v0.1.3 &>/dev/null
fi
echo "Repo cloned, building..."
cd $HOME/evmos
make install &>/dev/null
echo "Build succeeded"
evmosd config chain-id evmos_9000-1 &>/dev/null
evmosd config keyring-backend file &>/dev/null
evmosd init "$EVMOS_NODENAME" --chain-id evmos_9000-1 &>/dev/null
wget -qO $HOME/.evmosd/config/genesis.json https://raw.githubusercontent.com/tharsis/testnets/main/arsia_mons/genesis.json &>/dev/null
bootstrap_node="http://5.189.156.65:26657"; \
latest_height=`wget -qO- "${bootstrap_node}/block" | jq -r ".result.block.header.height"`; \
block_height=$((latest_height - 2000)); \
trust_hash=`wget -qO- "${bootstrap_node}/block?height=${block_height}" | jq -r ".result.block_id.hash"`; \
sed -i -e "s%^moniker *=.*%moniker = \"$EVMOS_NODENAME\"%; "\
"s%^seeds *=.*%seeds = \"c36cec90ded95d162b85f8ecd00ecd7c8849ca75@arsiamons.seed.evmos.org:26656,`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/main/arsia_mons/seeds.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"847e72f31e1f87e8059231b4b9e3302989c22d3a@5.189.156.65:26656,`wget -qO - https://raw.githubusercontent.com/Kallen-c/Evmos/main/peers.txt | tr '\n' ',' | sed 's%,$%%'`,`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/main/arsia_mons/peers.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
"s%^enable *=.*%enable = false%; "\
"s%^rpc_servers *=.*%rpc_servers = \"${bootstrap_node},${bootstrap_node}\"%; "\
"s%^trust_height *=.*%trust_height = $block_height%; "\
"s%^trust_hash *=.*%trust_hash = \"$trust_hash\"%" $HOME/.evmosd/config/config.toml
echo "Node config succeeded"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/evmos.service
[Unit]
Description=Evmos Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which evmosd) start
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable evmos &>/dev/null
sudo systemctl start evmos


evmosd keys add "$EVMOS_NODENAME" --keyring-backend file

sudo systemctl stop evmos
evmosd unsafe-reset-all
rm -f $HOME/.evmosd/config/genesis.json
evmosd init "$EVMOS_NODENAME" --chain-id=evmos_9000-2
evmosd add-genesis-account $(evmosd keys show "$EVMOS_NODENAME" -a) 1000000000000aphoton

evmosd gentx "$EVMOS_NODENAME" 1000000000000aphoton \
--commission-rate=0.1 \
--commission-max-rate=1 \
--commission-max-change-rate=0.1 \
--pubkey $(evmosd tendermint show-validator) \
--chain-id=evmos_9000-2

echo -e "\033[35m"
echo -e "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
echo -e "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
echo -e "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
echo -e "gentx json for github:"
echo -e ""
cat $HOME/.evmosd/config/gentx/gentx-*.json

echo -e "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
echo -e "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
echo -e "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"

echo "Service files created, return to guide"
echo -e "\033[0m"
