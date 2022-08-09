import Overlay from './overlay.js';
import Control from './control.js';
import { AwsRum } from 'aws-rum-web';
function App() {

  try {
    const config = {
      sessionSampleRate: 1,
      guestRoleArn: "arn:aws:iam::630895193694:role/RUM-Monitor-eu-west-2-630895193694-2597118500661-Unauth",
      identityPoolId: "eu-west-2:9a4c3406-9767-4346-a0a0-93ccf59cb1d9",
      endpoint: "https://dataplane.rum.eu-west-2.amazonaws.com",
      telemetries: ["performance","errors","http"],
      allowCookies: true,
      enableXRay: true
    };
  
    const APPLICATION_ID = 'db2abe6a-eb26-498e-9fca-a640a53df6f0';
    const APPLICATION_VERSION = '1.0.0';
    const APPLICATION_REGION = 'eu-west-2';
  
    const awsRum = new AwsRum(
      APPLICATION_ID,
      APPLICATION_VERSION,
      APPLICATION_REGION,
      config
    );
  } catch (error) {
    // Ignore errors thrown during CloudWatch RUM web client initialization
  }


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
