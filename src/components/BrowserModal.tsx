import { VFC, useState, useEffect } from "react";
import {
  ModalRoot,
  DialogBody,
  DialogControlsSection,
  DialogButton,
  TextField,
  staticClasses,
  ConfirmModal,
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
          <div className="decky-browser-nav">
            <button
              className="decky-browser-nav-button"
              onClick={handleGoBack}
              disabled={isLoading}
              title="Back"
            >
              ←
            </button>
            <button
              className="decky-browser-nav-button"
              onClick={handleGoForward}
              disabled={isLoading}
              title="Forward"
            >
              →
            </button>
            <button
              className="decky-browser-nav-button"
              onClick={handleRefresh}
              disabled={isLoading}
              title="Refresh"
            >
              ↻
            </button>
            <button
              className="decky-browser-nav-button"
              onClick={handleGoHome}
              disabled={isLoading}
              title="Home"
            >
              🏠
            </button>
          </div>

          {/* URL Bar */}
          <div className="decky-browser-url-bar">
            <input
              className="decky-browser-url-input"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Enter URL or search term..."
            />
            <button 
              className="decky-browser-go-button"
              onClick={handleNavigate} 
              disabled={isLoading}
            >
              Go
            </button>
          </div>

          {isLoading && (
            <div className="decky-browser-loading">
              Loading...
            </div>
          )}
        </DialogControlsSection>

        {/* Browser Content */}
        <div className="decky-browser-webview-container">
          <webview
            id="browser-webview"
            src={currentUrl}
            className="decky-browser-webview"
            allowpopups={true}
            useragent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
          />
        </div>
      </DialogBody>
    </ConfirmModal>
  );
};

export default BrowserModal;