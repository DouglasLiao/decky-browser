import { VFC, useState, useEffect } from "react";
import {
  ConfirmModal,
  DialogBody,
  DialogControlsSection,
} from "decky-frontend-lib";

interface BrowserContainerModalProps {
  serverAPI: any;
}

const BrowserContainerModal: VFC<BrowserContainerModalProps> = ({ serverAPI }) => {
  const [url, setUrl] = useState("https://www.google.com");
  const [isLoading, setIsLoading] = useState(true);
  const [containerStatus, setContainerStatus] = useState("checking");
  const [browserUrl, setBrowserUrl] = useState("");

  useEffect(() => {
    checkContainerStatus();
  }, []);

  const checkContainerStatus = async () => {
    try {
      setContainerStatus("checking");
      
      // Verificar se o container está rodando
      const status = await serverAPI.callPluginMethod("check_browser_container", {});
      
      if (status.success && status.result.running) {
        setContainerStatus("running");
        setBrowserUrl(status.result.url);
        setIsLoading(false);
      } else {
        setContainerStatus("starting");
        await startBrowserContainer();
      }
    } catch (error) {
      console.error("Erro ao verificar container:", error);
      setContainerStatus("error");
      setIsLoading(false);
    }
  };

  const startBrowserContainer = async () => {
    try {
      setContainerStatus("starting");
      
      const result = await serverAPI.callPluginMethod("start_browser_container", {});
      
      if (result.success) {
        setContainerStatus("running");
        setBrowserUrl(result.result.url);
        setIsLoading(false);
      } else {
        setContainerStatus("error");
        setIsLoading(false);
      }
    } catch (error) {
      console.error("Erro ao iniciar container:", error);
      setContainerStatus("error");
      setIsLoading(false);
    }
  };

  const navigateTo = async (newUrl: string) => {
    try {
      setIsLoading(true);
      const formattedUrl = newUrl.includes("://") ? newUrl : `https://${newUrl}`;
      
      await serverAPI.callPluginMethod("navigate_browser", { url: formattedUrl });
      setUrl(formattedUrl);
      setIsLoading(false);
    } catch (error) {
      console.error("Erro ao navegar:", error);
      setIsLoading(false);
    }
  };

  const handleNavigate = () => {
    if (url.trim()) {
      navigateTo(url);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      handleNavigate();
    }
  };

  const handleGoHome = () => {
    navigateTo("https://www.google.com");
  };

  const restartContainer = async () => {
    try {
      setContainerStatus("restarting");
      setIsLoading(true);
      
      await serverAPI.callPluginMethod("restart_browser_container", {});
      
      // Aguardar um pouco e verificar status novamente
      setTimeout(() => {
        checkContainerStatus();
      }, 3000);
    } catch (error) {
      console.error("Erro ao reiniciar container:", error);
      setContainerStatus("error");
      setIsLoading(false);
    }
  };

  const getStatusMessage = () => {
    switch (containerStatus) {
      case "checking":
        return "Verificando container...";
      case "starting":
        return "Iniciando browser isolado...";
      case "restarting":
        return "Reiniciando container...";
      case "running":
        return "Browser rodando em container isolado";
      case "error":
        return "Erro no container do browser";
      default:
        return "Status desconhecido";
    }
  };

  const getStatusColor = () => {
    switch (containerStatus) {
      case "running":
        return "#4ade80";
      case "error":
        return "#ef4444";
      default:
        return "#f59e0b";
    }
  };

  return (
    <ConfirmModal
      strTitle="Browser Isolado (Docker)"
      strOKButtonText="Fechar"
      onOK={() => window.history.back()}
      onCancel={() => window.history.back()}
      bDestructiveWarning={false}
    >
      <DialogBody>
        {/* Status do Container */}
        <DialogControlsSection>
          <div style={{ 
            padding: "10px", 
            borderRadius: "4px", 
            backgroundColor: "#1a1a1a",
            marginBottom: "10px",
            textAlign: "center"
          }}>
            <div style={{ 
              color: getStatusColor(),
              fontWeight: "bold",
              marginBottom: "5px"
            }}>
              {getStatusMessage()}
            </div>
            {browserUrl && (
              <div style={{ fontSize: "12px", color: "#aaa" }}>
                Container: {browserUrl}
              </div>
            )}
          </div>
        </DialogControlsSection>

        {/* Controles de Navegação */}
        {containerStatus === "running" && (
          <DialogControlsSection>
            <div style={{
              display: "flex",
              gap: "8px",
              marginBottom: "10px"
            }}>
              <button
                onClick={() => navigateTo("javascript:history.back()")}
                disabled={isLoading}
                title="Voltar"
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
                onClick={() => navigateTo("javascript:history.forward()")}
                disabled={isLoading}
                title="Avançar"
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
                onClick={() => navigateTo("javascript:location.reload()")}
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
              <button
                onClick={restartContainer}
                disabled={isLoading}
                title="Reiniciar Container"
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
                🔄
              </button>
            </div>

            {/* Barra de URL */}
            <div style={{
              display: "flex",
              gap: "8px",
              marginBottom: "10px"
            }}>
              <input
                value={url}
                onChange={(e) => setUrl(e.target.value)}
                onKeyPress={handleKeyPress}
                placeholder="Digite URL ou termo de busca..."
                disabled={isLoading}
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
                Ir
              </button>
            </div>

            {isLoading && (
              <div style={{
                textAlign: "center",
                margin: "10px 0",
                color: "#dcdedf",
                fontSize: "14px"
              }}>
                Navegando...
              </div>
            )}
          </DialogControlsSection>
        )}

        {/* Área do Browser */}
        {containerStatus === "running" && browserUrl ? (
          <div style={{
            width: "100%",
            height: "500px",
            border: "1px solid #3d4450",
            borderRadius: "4px",
            overflow: "hidden",
            backgroundColor: "#0e141b"
          }}>
            <iframe
              src={browserUrl}
              title="Browser Isolado"
              frameBorder="0"
              allowFullScreen
              style={{
                width: "100%",
                height: "100%",
                display: "block",
                border: "none"
              }}
            />
          </div>
        ) : containerStatus === "error" ? (
          <div style={{ 
            textAlign: "center", 
            padding: "40px",
            color: "#ef4444"
          }}>
            <div style={{ fontSize: "48px", marginBottom: "20px" }}>⚠️</div>
            <div style={{ fontSize: "18px", marginBottom: "10px" }}>
              Erro no Container do Browser
            </div>
            <div style={{ fontSize: "14px", marginBottom: "20px", color: "#aaa" }}>
              O container Docker não pôde ser iniciado
            </div>
            <button
              onClick={checkContainerStatus}
              style={{
                padding: "8px 16px",
                background: "#0077be",
                border: "1px solid #005a8b",
                borderRadius: "4px",
                color: "white",
                cursor: "pointer"
              }}
            >
              Tentar Novamente
            </button>
          </div>
        ) : (
          <div style={{ 
            textAlign: "center", 
            padding: "40px",
            color: "#f59e0b"
          }}>
            <div style={{ fontSize: "48px", marginBottom: "20px" }}>🐳</div>
            <div style={{ fontSize: "18px", marginBottom: "10px" }}>
              Preparando Browser Isolado
            </div>
            <div style={{ fontSize: "14px", color: "#aaa" }}>
              {getStatusMessage()}
            </div>
          </div>
        )}
      </DialogBody>
    </ConfirmModal>
  );
};

export default BrowserContainerModal;