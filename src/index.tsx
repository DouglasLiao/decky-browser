import {
  definePlugin,
  staticClasses,
  Router,
  ModalRoot,
  showModal,
} from "decky-frontend-lib";

import { VFC } from "react";
import { FaGlobe } from "react-icons/fa";

import BrowserModal from "./components/BrowserModal";
import BrowserContainerModal from "./components/BrowserContainerModal";
import "./styles.css";

const Content: VFC<{ serverAPI: any }> = ({ serverAPI }) => {
  const openBrowser = () => {
    showModal(
      <ModalRoot>
        <BrowserModal serverAPI={serverAPI} />
      </ModalRoot>
    );
  };

  const openContainerBrowser = () => {
    showModal(
      <ModalRoot>
        <BrowserContainerModal serverAPI={serverAPI} />
      </ModalRoot>
    );
  };

  return (
    <div className="decky-browser-container">
      <div className="decky-browser-title">
        Simple Browser
      </div>
      <div className="decky-browser-button-container">
        <button
          className="decky-browser-open-button"
          onClick={openBrowser}
          style={{ marginBottom: "10px" }}
        >
          <FaGlobe />
          Browser WebView
        </button>
        
        <button
          className="decky-browser-open-button"
          onClick={openContainerBrowser}
          style={{ 
            background: "linear-gradient(135deg, #1e40af, #1e3a8a)",
            marginBottom: "5px"
          }}
        >
          🐳
          Browser Isolado (Docker)
        </button>
        
        <div style={{ 
          fontSize: "12px", 
          color: "#888", 
          textAlign: "center",
          marginTop: "10px"
        }}>
          Browser isolado roda em container Docker<br/>
          independente das atualizações do Steam Deck
        </div>
      </div>
    </div>
  );
};

export default definePlugin((serverApi: any) => {
  return {
    title: <div className={staticClasses.Title}>Simple Browser</div>,
    content: <Content serverAPI={serverApi} />,
    icon: <FaGlobe />,
    onDismount() {
      // Cleanup if needed
    },
  };
});