import React, { Component } from 'react'

import ErrorHandler from './error'

export default class Shortener extends Component {
  state = {
    source: '',
    loading: false,
    error: null,
    success: null
  }

  constructor (props) {
    super(props)

    this.updateSource = this.updateSource.bind(this)
    this.shortenUrl = this.shortenUrl.bind(this)
    this.renderForm = this.renderForm.bind(this)
    this.closeMessage = this.closeMessage.bind(this)
  }

  updateSource (e) {
    this.setState({
      source: e.target.value
    })
  }

  shortenUrl (e) {
    e.preventDefault()
    this.setState({ loading: true, error: null, success: null })

    const endpoint = '/api/v1/short_urls'

    const data = { shorturl: { source: this.state.source } }
    fetch(endpoint, {
      method: 'POST', // *GET, POST, PUT, DELETE, etc.
      // mode: 'cors', // no-cors, *cors, same-origin
      cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
      credentials: 'same-origin', // include, *same-origin, omit
      headers: {
        'Content-Type': 'application/json'
      },
      redirect: 'follow', // manual, *follow, error
      referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
      body: JSON.stringify(data) // body data type must match "Content-Type" header
    })
      .then((response) => {
        return response.json().then(data => ({
          data: data,
          status: response.status,
          ok: response.ok
        }))
      })
      .then((res) => {
        if (!res.ok) {
          throw res
        }
        this.setState({ success: res.data })
      })
      .catch((error) => {
        this.setState({ error: error })
      })
      .finally(() => this.setState({ loading: false }))
  }

  closeMessage () {
    this.setState({ error: null, success: null })
  }

  renderSuccess () {
    if (this.state.success) {
      const shorturl = `${document.location.origin}/${this.state.success.key}`
      return (
        <article className="message is-success">
          <div className="message-header">
            <p>Created!</p>
            <button className="delete" aria-label="delete" onClick={this.closeMessage}></button>
          </div>
          <div className="message-body">
            You can access your link at <a href={shorturl} target="_blank" rel="noreferrer" >{shorturl}</a>
          </div>
        </article>
      )
    }
  }

  renderError () {
    if (this.state.error) {
      return (
        <ErrorHandler
          requestError={this.state.error}
          isActive={this.state.error !== null}
          dismissAction={this.closeMessage}
        />
      )
    }
  }

  renderForm () {
    return (
      <form className="column" onSubmit={this.shortenUrl}>
        <div className="field has-addons">
          <p className="control has-icons-right" style={{ width: '100%' }} >
            <input className="input is-large" aria-label="Source Url" type="text" placeholder="Add your link" value={this.state.source} onChange={this.updateSource} />
          </p>
          <p className="control">
            <button type="submit" className="button is-large is-warning" aria-label="Shorten Url">
              {this.state.loading ? <span className ="spinner is-loading" aria-label="Shortening">&nbsp;</span> : 'Shorten'}
            </button>
          </p>
        </div>
      </form>
    )
  }

  render () {
    return (
      <div className="container">
        {this.renderSuccess()}
        {this.renderError()}
        <div className="columns">
          {this.renderForm()}
        </div>
      </div>
    )
  }
}
