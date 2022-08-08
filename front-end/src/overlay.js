import React from 'react';
import Lowerthird from './lowerthird';

export default class Overlay extends React.Component{
    constructor(props){
        super(props)
        this.state = {
            numer: 0,
            lowerthirds: NaN
        }
        
    }
    getCurrentOverlay(){
        const url = 'https://ujr0uayvh8.execute-api.eu-west-2.amazonaws.com/overlay/current_overlay'
        fetch(url)
        .then(res => res.json())
        .then(
            (result) => {
                this.getOverlay(result)
            },
            (error) =>{ 
                console.log(error)
            }
        )
        
    }
    getOverlay(number){
        const url = 'https://ujr0uayvh8.execute-api.eu-west-2.amazonaws.com/overlay/get_overlay?overlay='+ number
        fetch(url)
        .then(res => res.json())
        .then(
            (result) => {
                const lowerthirds = []
                for (const key in result){
                    if (result[key].Lowerthird){
                        lowerthirds.push(result[key])
                    }
                }
                this.setState({numer: result,lowerthirds: lowerthirds});
                this.timer = setTimeout(() => this.getCurrentOverlay(), 1);
            },
            (error) =>{ 
                console.log(error)
            }
        )
    }
    componentDidMount(){
        this.getCurrentOverlay()
    }
    componentWillUnmount(){
        clearTimeout(this.timer)
    }
    render(){
        if(!this.state.lowerthirds){
            return(<div />)
        }
        return (
            <div id="overlay" style={{width: "1920px", height:"1080px"}}>
                {this.state.lowerthirds.map((lower, index) =>
                <div key={index}>
                    <Lowerthird index={lower.Lowerthird} Style={lower.Style} config={lower.config}/>
                </div>
                )}
                
            </div>
        )
    }
}