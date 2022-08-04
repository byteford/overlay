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
    default:
      return (
        <div className="App">
          <Overlay></Overlay>
        </div>
      );
  }
}

export default App;
