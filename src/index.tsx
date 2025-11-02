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
import "./styles.css";

const Content: VFC<{ serverAPI: any }> = ({ serverAPI }) => {
  const openBrowser = () => {
    showModal(
      <ModalRoot>
        <BrowserModal serverAPI={serverAPI} />
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
        >
          <FaGlobe />
          Open Browser
        </button>
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