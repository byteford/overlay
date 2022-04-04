import React from 'react';


export default class Lowerthird extends React.Component{
    constructor(props){
        super(props)
        this.state = {
            name: "",
            role: "",
            social: ""
        }
        
    }
    getLowerThird(){
        const url = 'https://b6pgciri1i.execute-api.eu-west-2.amazonaws.com/default/get_lowerthird?Index='+ this.props.index
        fetch(url)
        .then(res => res.json())
        .then(
            (result) => {
                this.setState({"name":result.Name,"role":result.Role,"social":result.Social })
            },
            (error) =>{ console.log(error)}
        )
    }
    componentDidMount(){
        this.interval = setInterval(() => this.getLowerThird(), 1000)
        
    }
    componentWillUnmount(){
        clearInterval(this.interval)
    }
    shouldComponentUpdate(nextProps,nextState){
        if (nextState.name !== this.state.name){
            return true
        }
        if (nextState.role !== this.state.role){
            return true
        }
        if (nextState.social !== this.state.social){
            return true
        }
        if(nextProps){
            return true
        }
        return false
    }
    render(){
        const url = "https://htkgx0tjcf.execute-api.eu-west-2.amazonaws.com/overlay/lowerthird?role="+this.state.role+"&social="+this.state.social+"&name="+this.state.name+"&role_size="+this.props.config.Role.Font_size+"&role_loc_x="+this.props.config.Role.X+"&role_loc_y="+this.props.config.Role.Y+"&social_size"+this.props.config.Social.Font_size+"&social_loc_x="+this.props.config.Social.X+"&social_loc_y="+this.props.config.Social.Y+"&name_size="+this.props.config.Name.Font_size+"&name_loc_x="+this.props.config.Name.X+"&name_loc_y="+this.props.config.Name.Y
        return (
            <div className="lowerthird" style={this.props.Style}>
                <img alt="" src={url} width="100%" />
            </div>
        )
    }
}