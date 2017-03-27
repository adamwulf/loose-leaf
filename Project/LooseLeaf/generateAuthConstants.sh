if [ ! -f AppIds.plist ]; then
echo "error: AppIds.plist is missing. Copy AppIds-Template.plist to AppIds.plist and fill with your API keys."
exit 1
fi


FacebookAppId="$(/usr/libexec/PlistBuddy -c 'print :FacebookAppId' AppIds.plist)"
PinterestAppId="$(/usr/libexec/PlistBuddy -c 'print :PinterestAppId' AppIds.plist)"
MixpanelTokenDebug="$(/usr/libexec/PlistBuddy -c 'print :MixpanelTokenDebug' AppIds.plist)"
MixpanelTokenProd="$(/usr/libexec/PlistBuddy -c 'print :MixpanelTokenProd' AppIds.plist)"
ImgurClientID="$(/usr/libexec/PlistBuddy -c 'print :ImgurClientID' AppIds.plist)"
ImgurClientSecret="$(/usr/libexec/PlistBuddy -c 'print :ImgurClientSecret' AppIds.plist)"
MashapeClientID="$(/usr/libexec/PlistBuddy -c 'print :MashapeClientID' AppIds.plist)"
TwitterKey="$(/usr/libexec/PlistBuddy -c 'print :TwitterKey' AppIds.plist)"
TwitterSecret="$(/usr/libexec/PlistBuddy -c 'print :TwitterSecret' AppIds.plist)"

echo "FacebookAppId: ${FacebookAppId}"
echo "PinterestAppId: ${PinterestAppId}"
echo "MixpanelTokenDebug: ${MixpanelTokenDebug}"
echo "MixpanelTokenProd: ${MixpanelTokenProd}"
echo "ImgurClientID: ${ImgurClientID}"
echo "ImgurClientSecret: ${ImgurClientSecret}"
echo "MashapeClientID: ${MashapeClientID}"
echo "TwitterKey: ${TwitterKey}"
echo "TwitterSecret: ${TwitterSecret}"


cp AuthConstants-Template.h AuthConstants.h

sed -i '' "s/YOUR_FACEBOOK_APP_ID/${FacebookAppId}/g" AuthConstants.h
sed -i '' "s/YOUR_PINTEREST_APP_ID/${PinterestAppId}/g" AuthConstants.h
sed -i '' "s/YOUR_DEBUG_MIXPANEL_TOKEN/${MixpanelTokenDebug}/g" AuthConstants.h
sed -i '' "s/YOUR_PROD_MIXPANEL_TOKEN/${MixpanelTokenProd}/g" AuthConstants.h
sed -i '' "s/YOUR_IMGUR_CLIENT_ID/${ImgurClientID}/g" AuthConstants.h
sed -i '' "s/YOUR_IMGUR_CLIENT_SECRET/${ImgurClientSecret}/g" AuthConstants.h
sed -i '' "s/YOUR_MASHAPE_CLIENT_ID/${MashapeClientID}/g" AuthConstants.h
sed -i '' "s/YOUR_FACEBOOK_APP_ID/${TwitterKey}/g" AuthConstants.h
sed -i '' "s/YOUR_FACEBOOK_APP_ID/${TwitterSecret}/g" AuthConstants.h

echo "Wrote AuthConstants.h"
