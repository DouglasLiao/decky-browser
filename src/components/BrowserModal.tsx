import { VFC, useState, useEffect } from "react";
import {
  ConfirmModal,
  DialogBody,
  DialogControlsSection,
} from "decky-frontend-lib";

interface BrowserModalProps {
  serverAPI: any;
}

const BrowserModal: VFC<BrowserModalProps> = ({ serverAPI }) => {
  const [url, setUrl] = useState("https://www.google.com");
  const [currentUrl, setCurrentUrl] = useState("https://www.google.com");
  const [isLoading, setIsLoading] = useState(false);

  const handleNavigate = () => {
    if (url.trim()) {
      // Adiciona https:// se não tiver protocolo
      const formattedUrl = url.includes("://") ? url : `https://${url}`;
      setCurrentUrl(formattedUrl);
      setIsLoading(true);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      handleNavigate();
    }
  };

  const handleGoHome = () => {
    setUrl("https://www.google.com");
    setCurrentUrl("https://www.google.com");
    setIsLoading(true);
  };

  const handleGoBack = () => {
    const webview = document.getElementById("browser-webview") as any;
    if (webview && webview.canGoBack) {
      webview.goBack();
    }
  };

  const handleGoForward = () => {
    const webview = document.getElementById("browser-webview") as any;
    if (webview && webview.canGoForward) {
      webview.goForward();
    }
  };

  const handleRefresh = () => {
    const webview = document.getElementById("browser-webview") as any;
    if (webview) {
      webview.reload();
      setIsLoading(true);
    }
  };

  const handleWebViewLoad = () => {
    setIsLoading(false);
    const webview = document.getElementById("browser-webview") as any;
    if (webview && webview.src) {
      setUrl(webview.src);
    }
  };

  useEffect(() => {
    const webview = document.getElementById("browser-webview") as any;
    if (webview) {
      webview.addEventListener("dom-ready", handleWebViewLoad);
      webview.addEventListener("did-finish-load", handleWebViewLoad);
      
      return () => {
        webview.removeEventListener("dom-ready", handleWebViewLoad);
        webview.removeEventListener("did-finish-load", handleWebViewLoad);
      };
    }
  }, []);

  return (
    <ConfirmModal
      strTitle="Simple Browser"
      strOKButtonText="Close"
      onOK={() => window.history.back()}
      onCancel={() => window.history.back()}
      bDestructiveWarning={false}
    >
      <DialogBody>
        {/* Navigation Bar */}
        <DialogControlsSection>
          <div style={{
            display: "flex",
            gap: "8px",
            marginBottom: "10px"
          }}>
            <button
              onClick={handleGoBack}
              disabled={isLoading}
              title="Back"
              style={{
                minWidth: "40px",
                padding: "8px",
                background: "#3d4450",
                border: "1px solid #5c6b7a",
                borderRadius: "4px",
                color: "white",
                cursor: "pointer"
              }}
            >
              ←
            </button>
            <button
              onClick={handleGoForward}
              disabled={isLoading}
              title="Forward"
              style={{
                minWidth: "40px",
                padding: "8px",
                background: "#3d4450",
                border: "1px solid #5c6b7a",
                borderRadius: "4px",
                color: "white",
                cursor: "pointer"
              }}
            >
              →
            </button>
            <button
              onClick={handleRefresh}
              disabled={isLoading}
              title="Refresh"
              style={{
                minWidth: "40px",
                padding: "8px",
                background: "#3d4450",
                border: "1px solid #5c6b7a",
                borderRadius: "4px",
                color: "white",
                cursor: "pointer"
              }}
            >
              ↻
            </button>
            <button
              onClick={handleGoHome}
              disabled={isLoading}
              title="Home"
              style={{
                minWidth: "40px",
                padding: "8px",
                background: "#3d4450",
                border: "1px solid #5c6b7a",
                borderRadius: "4px",
                color: "white",
                cursor: "pointer"
              }}
            >
              🏠
            </button>
          </div>

          {/* URL Bar */}
          <div style={{
            display: "flex",
            gap: "8px",
            marginBottom: "10px"
          }}>
            <input
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Enter URL or search term..."
              style={{
                flex: "1",
                padding: "8px",
                background: "#0e141b",
                border: "1px solid #3d4450",
                borderRadius: "4px",
                color: "white",
                fontSize: "14px"
              }}
            />
            <button 
              onClick={handleNavigate} 
              disabled={isLoading}
              style={{
                padding: "8px 16px",
                background: "#0077be",
                border: "1px solid #005a8b",
                borderRadius: "4px",
                color: "white",
                cursor: "pointer"
              }}
            >
              Go
            </button>
          </div>

          {isLoading && (
            <div style={{
              textAlign: "center",
              margin: "10px 0",
              color: "#dcdedf",
              fontSize: "14px"
            }}>
              Loading...
            </div>
          )}
        </DialogControlsSection>

        {/* Browser Content */}
        <div style={{
          width: "100%",
          height: "500px",
          border: "1px solid #3d4450",
          borderRadius: "4px",
          overflow: "hidden",
          backgroundColor: "#0e141b"
        }}>
          <webview
            id="browser-webview"
            src={currentUrl}
            allowpopups={true}
            useragent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            style={{
              width: "100%",
              height: "100%",
              display: "block",
              border: "none"
            }}
          />
        </div>
      </DialogBody>
    </ConfirmModal>
  );
};

export default BrowserModal;