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
    getOverlay(){
        const url = 'https://b6pgciri1i.execute-api.eu-west-2.amazonaws.com/default/get_overlay?overlay='+ this.state.numer
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
                this.setState({lowerthirds: lowerthirds});
            },
            (error) =>{ console.log(error)}
        )
    }
    componentDidMount(){
        this.interval = setInterval(() => this.getOverlay(), 1000)
        
    }
    componentWillUnmount(){
        clearInterval(this.interval)
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