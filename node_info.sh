#!/bin/bash
# Config
daemon="`which evmosd`"
token_name="photon"
node_dir="$HOME/.evmosd/"
wallet_name="$EVMOS_NODENAME"
wallet_address="$EVMOS_NODENAME"
wallet_address_variable="evmos_wallet_address"

# Default variables
language="EN"
raw_output="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/Kallen-c/utils/main/colors.sh) --
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/Kallen-c/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script shows information about a Evmos node"
		echo
		echo -e "Usage: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help               show help page"
		echo -e "  -l, --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                           LANGUAGE is '${C_LGn}EN${RES}' (default), '${C_LGn}RU${RES}'"
		echo -e "  -ro, --raw-output        the raw JSON output"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/Kallen-c/Evmos/blob/main/node_info.sh - script URL"
		echo -e "         (you can send Pull request with new texts to add a language)"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-l*|--language*)
		if ! grep -q "=" <<< $1; then shift; fi
		language=`option_value $1`
		shift
		;;
	-ro|--raw-output)
		raw_output="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }

main() {
	# Texts
	if [ "$language" = "RU" ]; then
		local t_ewa="Для просмотра баланса кошелька необходимо добавить его в систему виде переменной, поэтому ${C_LGn}введите пароль от кошелька${RES}"
		local t_ewa_err="${C_LR}Не удалось получить адрес кошелька!${RES}"
		local t_nn="\nНазвание ноды:              ${C_LGn}%s${RES}"
		local t_id="Keybase ключ:               ${C_LGn}%s${RES}"
		local t_si="Сайт:                       ${C_LGn}%s${RES}"
		local t_det="Описание:                   ${C_LGn}%s${RES}\n"

		local t_net="Сеть:                       ${C_LGn}%s${RES}"
		local t_ni="ID ноды:                    ${C_LGn}%s${RES}"
		local t_nv="Версия ноды:                ${C_LGn}%s${RES}"
		local t_lb="Последний блок:             ${C_LGn}%s${RES}"
		local t_sy1="Нода синхронизирована:      ${C_LR}нет${RES}"
		local t_sy2="Осталось нагнать:           ${C_LR}%d-%d=%d (около %.2f мин.)${RES}"
		local t_sy3="Нода синхронизирована:      ${C_LGn}да${RES}"

		local t_va="\nАдрес валидатора:           ${C_LGn}%s${RES}"
		local t_pk="Публичный ключ валидатора:  ${C_LGn}%s${RES}"
		local t_nij1="Валидатор в тюрьме:         ${C_LR}да${RES}"
		local t_nij2="Валидатор в тюрьме:         ${C_LGn}нет${RES}"
		local t_del="Делегировано токенов:       ${C_LGn}%.4f${RES} ${token_name}"
		local t_vp="Весомость голоса:           ${C_LGn}%.4f${RES}\n"

		local t_wa="Адрес кошелька:             ${C_LGn}%s${RES}"
		local t_bal="Баланс:                     ${C_LGn}%.4f${RES} ${token_name}\n"
	# Send Pull request with new texts to add a language - https://github.com/Kallen-c/Evmos/blob/main/node_info.sh
	#elif [ "$language" = ".." ]; then
	else
		local t_ewa="To view the wallet balance, you have to add it to the system as a variable, so ${C_LGn}enter the wallet password${RES}"
		local t_ewa_err="${C_LR}Failed to get the wallet address!${RES}"
		local t_nn="\nMoniker:                 ${C_LGn}%s${RES}"
		local t_id="Keybase key:             ${C_LGn}%s${RES}"
		local t_si="Website:                 ${C_LGn}%s${RES}"
		local t_det="Details:                 ${C_LGn}%s${RES}\n"

		local t_net="Network:                 ${C_LGn}%s${RES}"
		local t_ni="Node ID:                 ${C_LGn}%s${RES}"
		local t_nv="Node version:            ${C_LGn}%s${RES}"
		local t_lb="Latest block height:     ${C_LGn}%s${RES}"
		local t_sy1="Node is synchronized:    ${C_LR}no${RES}"
		local t_sy2="It remains to catch up:  ${C_LR}%d-%d=%d (about %.2f min.)${RES}"
		local t_sy3="Node is synchronized:    ${C_LGn}yes${RES}"

		local t_va="\nValidator address:       ${C_LGn}%s${RES}"
		local t_pk="Validator public key:    ${C_LGn}%s${RES}"
		local t_nij1="Validator in a jail:     ${C_LR}yes${RES}"
		local t_nij2="Validator in a jail:     ${C_LGn}no${RES}"
		local t_del="Delegated tokens:        ${C_LGn}%.4f${RES} ${token_name}"
		local t_vp="Voting power:            ${C_LGn}%.4f${RES}\n"

		local t_wa="Wallet address:          ${C_LGn}%s${RES}"
		local t_bal="Balance:                 ${C_LGn}%.4f${RES} ${token_name}\n"
	fi

	# Actions
	sudo apt install bc -y &>/dev/null
	if [ -n "$wallet_name" ] && [ ! -n "$wallet_address" ]; then
		printf_n "$t_ewa"
		local wallet_address=`$daemon keys show "$wallet_name" -a`
		if [ -n "$wallet_address" ]; then
			. <(wget -qO- https://raw.githubusercontent.com/Kallen-c/utils/main/miscellaneous/insert_variable.sh) -n "$wallet_address_variable" -v "$wallet_address"
		else
			printf_n "$t_ewa_err"
		fi
	fi
	local node_tcp=`cat "${node_dir}config/config.toml" | grep -oPm1 "(?<=^laddr = \")([^%]+)(?=\")"`
	local status=`$daemon status --node "$node_tcp" 2>&1`
	local moniker=`jq -r ".NodeInfo.moniker" <<< $status`
	local node_info=`$daemon query staking validators --node "$node_tcp" --limit 10000 --output json | jq -r '.validators[] | select(.description.moniker=='\"$moniker\"')'`
	local identity=`jq -r ".description.identity" <<< $node_info`
	local website=`jq -r ".description.website" <<< $node_info`
	local details=`jq -r ".description.details" <<< $node_info`

	local network=`jq -r ".NodeInfo.network" <<< $status`
	local node_id=`jq -r ".NodeInfo.id" <<< $status`
	local node_version=`$daemon version`
	local latest_block_height=`jq -r ".SyncInfo.latest_block_height" <<< $status`
	local catching_up=`jq -r ".SyncInfo.catching_up" <<< $status`

	local validator_address=`jq -r ".operator_address" <<< $node_info`
	local validator_pub_key=`$daemon tendermint show-validator | tr "\"" "'"`
	local jailed=`jq -r ".jailed" <<< $node_info`
	local delegated=`bc -l <<< "$(jq -r ".tokens" <<< $node_info)/1000000000000000000"`
	local voting_power=`bc -l <<< "$(jq -r ".ValidatorInfo.VotingPower" <<< $status)/1000000000000"`
	if [ -n "$wallet_address" ]; then
		local balance=`bc -l <<< "$($daemon query bank balances "$wallet_address" -o json --node "http://arsiamons.rpc.evmos.org:26657/" | jq -r ".balances[0].amount")/1000000000000000000"`
	fi

	# Output
	if [ "$raw_output" = "true" ]; then
		printf_n '{"moniker": "%s", "identity": "%s", "website": "%s", "details": "%s", "network": "%s", "node_id": "%s", "node_version": "%s", "latest_block_height": %d, "catching_up": %b, "validator_address": "%s", "validator_pub_key": "%s", "jailed": %b, "delegated": %.4f, "voting_power": %.4f, "wallet_address": "%s", "balance": %.4f}' \
"$moniker" \
"$identity" \
"$website" \
"$details" \
"$network" \
"$node_id" \
"$node_version" \
"$latest_block_height" \
"$catching_up" \
"$validator_address" \
"$validator_pub_key" \
"$jailed" \
"$delegated" \
"$voting_power" \
"$wallet_address" \
"$balance" 2>/dev/null
	else
		printf_n "$t_nn" "$moniker"
		printf_n "$t_id" "$identity"
		printf_n "$t_si" "$website"
		printf_n "$t_det" "$details"

		printf_n "$t_net" "$network"
		printf_n "$t_ni" "$node_id"
		printf_n "$t_nv" "$node_version"
		printf_n "$t_lb" "$latest_block_height"
		if [ "$catching_up" = "true" ]; then
			local current_block=`wget -qO- "http://arsiamons.rpc.evmos.org:26657/abci_info" | jq -r ".result.response.last_block_height"`
			local diff=`bc -l <<< "$current_block-$latest_block_height"`
			local takes_time=`bc -l <<< "$diff/60/60"`
			printf_n "$t_sy1"
			printf_n "$t_sy2" "$current_block" "$latest_block_height" "$diff" "$takes_time"
		else
			printf_n "$t_sy3"
		fi

		printf_n "$t_va" "$validator_address"
		printf_n "$t_pk" "$validator_pub_key"
		if [ "$jailed" = "true" ]; then
			printf_n "$t_nij1"
		else
			printf_n "$t_nij2"
		fi
		printf_n "$t_del" "$delegated"
		printf_n "$t_vp" "$voting_power"

		if [ -n "$wallet_address" ]; then
			printf_n "$t_wa" "$wallet_address"
			printf_n "$t_bal" "$balance"
		fi
	fi
}

main
