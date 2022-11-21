module.exports = {
        defaultBrowser: "Google Chrome",
        rewrite: [{
                // rewrite http[s]://chime.aws/<meetingID> to chime://meeting?pin=meetingId>
                match: finicky.matchHostnames(["chime.aws"]),
                url: ({
                        url
                }) => ({
                        ...url,
                        host: "",
                        search: "pin=" + url.pathname.substr(1),
                        pathname: "meeting",
                        protocol: "chime"
                })
        }, /*{
                // rewrite http[s]://quip.com/<documentID>/* to quip://<documentID>
                match: finicky.matchHostnames(["quip-amazon.com"]),
                url: ({
                        url
                }) => ({
                        ...url,
                        host: "",
                        search: "",
                        pathname: url.pathname.split('/')[1] == "email" ? decodeURIComponent(url.search).split('/')[2].split('&')[0] : url.pathname.split('/')[1],
                        protocol: "quip"
                })
        },*/ {
                // rewrite https://amzn-aws.slack.com/archives/C016MF9NNTU To slack://channel?team=T016V3P6FHQ&id=C016MF9NNTU
                match: finicky.matchHostnames(["amzn-aws.slack.com"]),
                url: ({
                        url
                }) => ({
                        ...url,
                        host: url.pathname.split('/')[1] == "ssb" ? url.host : "",
                        search: "team=T016M3G1GHZ&id=" + url.pathname.split('/')[2],
                        pathname: url.pathname.split('/')[1] == "ssb" ? url.pathname : "channel",
                        protocol: url.pathname.split('/')[1] == "ssb" ? "https" : "slack"
                })
        }

        ],
        handlers: [
                {
                        match: /^https?:\/\/apple\.com\/.*$/,
                        browser: "Safari"
                },
                {
                        match: /^https?:\/\/isengard\.amazon\.com\/.*$/,
                        browser: "Firefox"
                },
                {
                        match: ({ url }) => url.pathname.endsWith(".xpi"),
                        browser: "Firefox"
                },
                {
                        // open chime: url in Chime.app
                        match: ({
                                url
                        }) => url.protocol === "chime",
                        browser: "Amazon Chime.app"
                },
                {
                        match: ({
                                url
                        }) => url.protocol === "quip",
                        browser: "/Applications/Quip.app"
                }, {
                        match: ({
                                url
                        }) => url.protocol === "slack",
                        browser: "/Applications/Slack.app"
                },
                {
                        match: "open.spotify.com*",
                        browser: "Spotify"
                },
                {
                        match: /zoom.us\/j\//,
                        browser: "us.zoom.xos"
                }
        ]
}
