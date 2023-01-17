while true 
do
	if pgrep Xcode; then
		echo "Sending Heartbeat"
		wakatime-cli --entity "MetalBox/Game/MainGameScene.swift"
	else
		echo "Xcode not running"
	fi

	sleep 60
done
