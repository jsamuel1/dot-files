export default {
  defaultBrowser: "Arc",

  options: {
    checkForUpdates: true,
    logRequests: false,
  },

  rewrite: [
    {
      // Rewrite http[s]://chime.aws/<meetingID> to chime://meeting?pin=meetingId>
      match: ["chime.aws"],
      url: (url) => ({
        protocol: "chime",
        host: "",
        pathname: "meeting",
        search: "pin=" + url.pathname.substring(1),
      }),
    },
    {
      // Force HTTPS for all HTTP URLs (security best practice)
      match: (url) => {
        const localDomains = ["localhost", "127.0.0.1"];
        return (
          url.protocol === "http:" &&
          !localDomains.some((domain) => url.host.includes(domain))
        );
      },
      url: (url) => {
        url.protocol = "https:";
        return url;
      },
    },
    {
      // Remove tracking parameters for privacy
      match: () => true,
      url: (url) => {
        const removeKeysStartingWith = ["utm_", "uta_", "mc_", "pk_"];
        const removeKeys = [
          "fbclid", "gclid", "msclkid", "twclid",
          "ref", "ref_", "referrer",
          "campaign", "source", "medium",
          "hsCtaTracking", "hsa_",
          "_ga", "_gl",
          "igshid", "igsh",
          "si",
        ];

        for (const key of [...url.searchParams.keys()]) {
          if (removeKeysStartingWith.some((prefix) => key.startsWith(prefix)) ||
              removeKeys.includes(key)) {
            url.searchParams.delete(key);
          }
        }
        return url;
      },
    },
  ],

  handlers: [
    {
      // Mobile app OAuth flows - use Safari for proper Universal Links callback
      match: (url, { opener }) =>
        opener.bundleId &&
        (url.href.toLowerCase().includes("forcemobileapp") ||
          url.href.includes("/mobile/auth") ||
          url.href.includes("/mobile/callback") ||
          url.href.includes("redirect_uri=") && url.href.includes("/mobile/")),
      browser: "Safari",
    },
    {
      // Apple domains work best with Safari
      match: ["apple.com/*", "*.apple.com/*"],
      browser: "Safari",
    },
    {
      // Isengard specifically in Firefox
      match: "isengard.amazon.com/*",
      browser: "Firefox",
    },
    {
      // Firefox extensions
      match: (url) => url.pathname.endsWith(".xpi"),
      browser: "Firefox",
    },
    {
      match: (url) => url.protocol === "quip:",
      browser: "/Applications/Quip.app",
    },
    {
      // Spotify links
      match: "open.spotify.com/*",
      browser: "Spotify",
    },
    {
      // Zoom meetings
      match: [/zoom\.us\/j\//, /zoom\.us\/join/, "*.zoom.us/j/*"],
      browser: "us.zoom.xos",
    },
  ],
};
