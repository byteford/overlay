import React from 'react';

export default class Control extends React.Component{
    constructor(props){
        super(props)
        this.state = {
            overlays: 2,
            numer: 0
        }
    }
    changeOverlay(newOverlay){
        console.log(newOverlay)
        const url = `https://ujr0uayvh8.execute-api.eu-west-2.amazonaws.com/overlay/current_overlay?overlay=${newOverlay}`
        fetch(url,{method: "PUT"})
        .then(() =>{
            const url = 'https://ujr0uayvh8.execute-api.eu-west-2.amazonaws.com/overlay/current_overlay'
            fetch(url)
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({numer: result});
                },
                (error) =>{ 
                    console.log(error)
                }
            )}
        )
    }

    render(){
        return (
            <div id="control" >
                <p>Current {this.state.numer}</p>
                {[...Array(this.state.overlays)].map((e,i) =>
                <button key={i} onClick={() => this.changeOverlay(i)}>
                    change {i}
                </button>
                )}
            </div>
        )
    }
}