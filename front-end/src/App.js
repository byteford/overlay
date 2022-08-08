import Overlay from './overlay.js';
import Control from './control.js';
function App() {
  var path = window.location.pathname;
  switch (path){
    case "/control":
      return (
        <div>
        <div className="App">
          <Control></Control>
        </div>
        </div>
      );
    case "/mask":
      return (
        <div style={{backgroundColor: "black"}}>
          <div className="App" style={{filter:"contrast(0) saturate(0) brightness(0) invert(1)"}}>
            <Overlay></Overlay>
          </div>
        </div>
      );
    default:
      return (
        <div>
          <div className="App" style={{filter:"contrast(1) saturate(1) brightness(1)"}}>
            <Overlay></Overlay>
          </div>
        </div>
      );
  }
}

export default App;
