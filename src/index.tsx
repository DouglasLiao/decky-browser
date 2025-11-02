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
    <div style={{
      marginTop: "50px",
      color: "white"
    }}>
      <div style={{
        fontSize: "20px",
        textAlign: "center",
        marginBottom: "20px"
      }}>
        Simple Browser
      </div>
      <div style={{
        textAlign: "center",
        marginTop: "20px",
        display: "flex",
        flexDirection: "column",
        gap: "10px",
        alignItems: "center"
      }}>
        <button
          onClick={openBrowser}
          style={{ 
            minHeight: "40px",
            minWidth: "200px",
            background: "linear-gradient(135deg, #0077be, #005a8b)",
            border: "none",
            borderRadius: "8px",
            color: "white",
            fontSize: "16px",
            fontWeight: "bold",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: "10px",
            transition: "all 0.3s ease"
          }}
        >
          <FaGlobe />
          Browser WebView
        </button>
        
        <button
          onClick={openContainerBrowser}
          style={{ 
            minHeight: "40px",
            minWidth: "200px",
            background: "linear-gradient(135deg, #1e40af, #1e3a8a)",
            border: "none",
            borderRadius: "8px",
            color: "white",
            fontSize: "16px",
            fontWeight: "bold",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: "10px",
            transition: "all 0.3s ease"
          }}
        >
          🐳
          Browser Isolado (Docker)
        </button>
        
        <div style={{ 
          fontSize: "12px", 
          color: "#888", 
          textAlign: "center",
          marginTop: "10px",
          maxWidth: "250px"
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