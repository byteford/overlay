import Overlay from './overlay.js';
import Control from './control.js';
function App() {
  var path = window.location.pathname;
  switch (path){
    case "/control":
      return (
        <div className="App">
          <Control></Control>
        </div>
      );
    case "/mask":
      return (
        <div style={{backgroundColor: "black"}}>
          <div className="App" style={{filter:"contrast(0) saturate(0) brightness(0) invert(1)", display: "initial"}}>
            <Overlay></Overlay>
          </div>
        </div>
      );
    default:
      return (
        <div className="App">
          <Overlay></Overlay>
        </div>
      );
  }
}

export default App;
