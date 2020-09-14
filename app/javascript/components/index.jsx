import React, { Component } from 'react'

import Shortener from './shortener'

export default class App extends Component {
  state = {
    source: '',
    loading: false,
    error: null,
    success: null
  }

  render () {
    return (
      <div className="container is-fluid">
        <section className="section">
          <div className="container">
            <h1 className="title">Shorten Your Url</h1>
            <Shortener />
          </div>
        </section>
      </div>
    )
  }
}
