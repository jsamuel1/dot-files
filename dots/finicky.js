module.exports = {
        defaultBrowser: "Arc",
        
        options: {
                // Check for updates automatically
                checkForUpdates: true,
                // Log requests for debugging (set to false in production)
                logRequests: false,
        },

        rewrite: [
                {
                        // Rewrite http[s]://chime.aws/<meetingID> to chime://meeting?pin=meetingId>
                        match: ["chime.aws"],
                        url: ({ url }) => ({
                                ...url,
                                host: "",
                                search: "pin=" + url.pathname.substring(1),
                                pathname: "meeting",
                                protocol: "chime"
                        })
                },
                /*{
                        // Rewrite http[s]://quip.com/<documentID>/* to quip://<documentID>
                        match: matchHostnames(["quip-amazon.com"]),
                        url: ({ url }) => ({
                                ...url,
                                host: "",
                                search: "",
                                pathname: url.pathname.split('/')[1] === "email" 
                                        ? decodeURIComponent(url.search).split('/')[2].split('&')[0] 
                                        : url.pathname.split('/')[1],
                                protocol: "quip"
                        })
                },*/
                {
                        // Rewrite https://amzn-aws.slack.com/archives/C016MF9NNTU to slack://channel?team=T016V3P6FHQ&id=C016MF9NNTU
                        match: ["amzn-aws.slack.com"],
                        url: ({ url }) => {
                                const pathParts = url.pathname.split('/');
                                const isSSB = pathParts[1] === "ssb";
                                
                                return {
                                        ...url,
                                        host: isSSB ? url.host : "",
                                        search: isSSB ? url.search : `team=T016M3G1GHZ&id=${pathParts[2]}`,
                                        pathname: isSSB ? url.pathname : "channel",
                                        protocol: isSSB ? "https" : "slack"
                                };
                        }
                },
                {
                        // Force HTTPS for all HTTP URLs (security best practice)
                        match: ({ url }) => url.protocol === "http",
                        url: ({ url }) => {
                                url.protocol = "https";
                                return url;
                        }
                },
                {
                        // Remove tracking parameters for privacy
                        match: () => true, // Apply to all URLs
                        url: ({ url }) => {
                                const removeKeysStartingWith = ["utm_", "uta_", "mc_", "pk_"]; // Remove parameters starting with these
                                const removeKeys = [
                                        "fbclid", "gclid", "msclkid", "twclid", // Click IDs
                                        "ref", "ref_", "referrer", // Referrer tracking
                                        "campaign", "source", "medium", // Campaign tracking
                                        "hsCtaTracking", "hsa_", // HubSpot tracking
                                        "_ga", "_gl", // Google Analytics
                                        "igshid", "igsh", // Instagram
                                        "si" // YouTube/Google
                                ];

                                if (!url.search) return url;

                                const cleanedParams = url.search
                                        .split("&")
                                        .map(param => param.split("="))
                                        .filter(([key]) => {
                                                // Remove if key starts with any of the prefixes
                                                if (removeKeysStartingWith.some(prefix => key.startsWith(prefix))) {
                                                        return false;
                                                }
                                                // Remove if key matches any of the exact keys
                                                if (removeKeys.includes(key)) {
                                                        return false;
                                                }
                                                return true;
                                        })
                                        .map(param => param.join("="));

                                return {
                                        ...url,
                                        search: cleanedParams.join("&")
                                };
                        }
                }
        ],

        handlers: [
                {
                        // Apple domains work best with Safari
                        match: [
                                "apple.com/*",
                                "*.apple.com/*"
                        ],
                        browser: "Safari"
                },
                {
                        // Isengard specifically in Firefox
                        match: "isengard.amazon.com/*",
                        browser: "Firefox"
                },
                {
                        // Firefox extensions
                        match: ({ url }) => url.pathname.endsWith(".xpi"),
                        browser: "Firefox"
                },
                {
                        // Custom protocol handlers
                        match: ({ url }) => url.protocol === "chime",
                        browser: "Amazon Chime"
                },
                {
                        match: ({ url }) => url.protocol === "quip",
                        browser: "/Applications/Quip.app"
                },
                {
                        match: ({ url }) => url.protocol === "slack",
                        browser: "/Applications/Slack.app"
                },
                {
                        // Spotify links
                        match: "open.spotify.com/*",
                        browser: "Spotify"
                },
                {
                        // Zoom meetings - improved pattern matching
                        match: [
                                /zoom\.us\/j\//,
                                /zoom\.us\/join/,
                                "*.zoom.us/j/*"
                        ],
                        browser: "us.zoom.xos"
                }
        ]
};
