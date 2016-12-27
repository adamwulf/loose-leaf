echo "read from: $(pwd)"

FacebookAppId="$(/usr/libexec/PlistBuddy -c 'print :FacebookAppId' AppIds.plist)"
PinterestAppId="$(/usr/libexec/PlistBuddy -c 'print :PinterestAppId' AppIds.plist)"
MixpanelTokenDebug="$(/usr/libexec/PlistBuddy -c 'print :MixpanelTokenDebug' AppIds.plist)"
MixpanelTokenProd="$(/usr/libexec/PlistBuddy -c 'print :MixpanelTokenProd' AppIds.plist)"
ImgurClientID="$(/usr/libexec/PlistBuddy -c 'print :ImgurClientID' AppIds.plist)"
ImgurClientSecret="$(/usr/libexec/PlistBuddy -c 'print :ImgurClientSecret' AppIds.plist)"
MashapeClientID="$(/usr/libexec/PlistBuddy -c 'print :MashapeClientID' AppIds.plist)"
TwitterKey="$(/usr/libexec/PlistBuddy -c 'print :TwitterKey' AppIds.plist)"
TwitterSecret="$(/usr/libexec/PlistBuddy -c 'print :TwitterSecret' AppIds.plist)"
FabricKey="$(/usr/libexec/PlistBuddy -c 'print :FabricKey' AppIds.plist)"

echo "FacebookAppId: ${FacebookAppId}"
echo "PinterestAppId: ${PinterestAppId}"
echo "MixpanelTokenDebug: ${MixpanelTokenDebug}"
echo "MixpanelTokenProd: ${MixpanelTokenProd}"
echo "ImgurClientID: ${ImgurClientID}"
echo "ImgurClientSecret: ${ImgurClientSecret}"
echo "MashapeClientID: ${MashapeClientID}"
echo "TwitterKey: ${TwitterKey}"
echo "TwitterSecret: ${TwitterSecret}"
echo "FabricKey: ${FabricKey}"


cd $1
cd LooseLeaf.app

echo "moving to:"
echo $1

plutil -convert xml1 Info.plist

sed -i '' "s/YOUR_FACEBOOK_APP_ID/${FacebookAppId}/g" Info.plist
sed -i '' "s/YOUR_PINTEREST_APP_ID/${PinterestAppId}/g" Info.plist
sed -i '' "s/YOUR_TWITTER_KEY/${TwitterKey}/g" Info.plist
sed -i '' "s/YOUR_TWITTER_SECRET/${TwitterSecret}/g" Info.plist
sed -i '' "s/YOUR_FABRIC_KEY/${FabricKey}/g" Info.plist

plutil -convert binary1 Info.plist

echo "Wrote Info.plist"
