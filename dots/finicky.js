module.exports = {
        defaultBrowser: "Google Chrome",
        rewrite: [ {
                // rewrite http[s]://chime.aws/<meetingID> to chime://meeting?pin=meetingId>
                match: finicky.matchHostnames( [ "chime.aws" ] ),
                url: ( {
                        url
                } ) => ( {
                        ...url,
                        host: "",
                        search: "pin=" + url.pathname.substr( 1 ),
                        pathname: "meeting",
                        protocol: "chime"
                } )
        }, {
                // rewrite http[s]://quip.com/<documentID>/* to quip://<documentID>
                match: finicky.matchHostnames( [ "quip-amazon.com" ] ),
                url: ( {
                        url
                } ) => ( {
                        ...url,
                        host: "",
                        search: "",
                        pathname: url.pathname.split( '/' )[ 1 ] == "email" ? decodeURIComponent(url.search).split('/')[2].split('&')[0] : url.pathname.split( '/' )[ 1 ],
                        protocol: "quip"
                } )
        } ],
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
                        // open chime: url in Chime.app
                        match: ( {
                                url
                        } ) => url.protocol === "chime",
                        browser: "Amazon Chime.app"
                },
                {
                        match: ( {
                                url
                        } ) => url.protocol === "quip",
                        browser: "/Applications/Quip.app"
                }
        ]
}
