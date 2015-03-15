$ ->

  converter = new Showdown.converter()

  CommentBox = React.createClass
    loadCommentsFromServer: ->
      $.ajax
        url: @props.url
        dataType: 'json'
      .done (data) =>
        @setState(data: data)
      .fail (xhr, status, err) =>
        console.error @props.url, status, err.toString()

    handleCommentSubmit: (comment) ->
      # ajax通信していたらラグがあるので先に描画
      comments = @state.data
      newComments = comments.concat([comment])
      @setState(data: newComments)

      $.ajax
        url: @props.url
        dataType: 'json'
        type: 'POST'
        data: comment: comment
      .done (data) =>
        @setState(data: data)
        #@loadCommentsFromServer
      .fail (xhr, status, err) =>
        console.error @props.url, status, err.toString()

    getInitialState: -> data: []

    render: ->
      `<div className="commentBox">
         <h3>コメント一覧</h3>
         <CommentList data={ this.state.data } />
         <CommentForm onCommentSubmit={ this.handleCommentSubmit } />
       </div>`

    componentDidMount: ->
      @loadCommentsFromServer()
      #setInterval @loadCommentsFromServer, @props.pollInterval

  CommentList = React.createClass
    render: ->
      commentNodes = @props.data.map (comment) ->
        `<Comment id={ comment.id } author={ comment.author } text={ comment.text }></Comment>` # thisがWindowオブジェクトに..?
      `<div className="commentList">
        <ul className="list-group">
          { commentNodes }
        </ul>
       </div>`

  Comment = React.createClass
    handleClick: (e) ->
      # できればstateを利用したい
      $(@refs.comment.getDOMNode()).remove()
      $.ajax
        url: '/api/comments/' + @props.id
        dataType: 'json'
        type: 'DELETE'
        data: id: @props.id
      .done (data) =>
        console.log(data)
      .fail (xhr, status, err) =>
        console.error(status, err.toString())

    render: ->
      #rawMarkup = converter.makeHtml @props.children.toString()
      `<li className="list-group-item" ref="comment">
      { this.props.author } : { this.props.text}
      <a className="comment-delete-btn btn-link" onClick={ this.handleClick }>削除</a>
     </li>`

  CommentForm = React.createClass
    handleSubmit: (e) ->
      e.preventDefault()
      author = @refs.author.getDOMNode().value.trim()
      text = @refs.text.getDOMNode().value.trim()
      return unless author and text
      @props.onCommentSubmit(author: author, text: text)
      @refs.author.getDOMNode().value = ''
      @refs.text.getDOMNode().value = ''

    render: ->
      `<form className="commentForm" onSubmit={ this.handleSubmit }>
         <div className="form-group">
           名前: <input type="text" ref="author" />
           コメント: <input type="text" ref="text" size="70"/>
         </div>
         <input className="btn btn-primary" type="submit" value="コメント" />
       </form>`

  React.render(
    #`<CommentBox url="/api/comments" pollInterval={ 2000 } />`,
    `<CommentBox url="/api/comments"/>`,
    $('#content')[0]
  )
