class Planit.Plan.Events

  # ------------------------------------------ Setup

  constructor: (@options) ->
    @container = @options.container
    @markersContainer = @container.find(".#{Planit.markerContainerClass}")
    if @container.find(".#{Planit.imageContainer} > img").length > 0
      @image = @container.find(".#{Planit.imageContainer} > img").first()

    # bind draggable events
    $(document).on('mousemove', @mousemove)
    $(document).on('mouseup', @mouseup)

  # ------------------------------------------ Refs

  markers: =>
    @markersContainer.find(".#{Planit.markerClass}")

  draggingMarker: =>
    @markersContainer.find(".#{Planit.markerClass}.#{Planit.draggingClass}")

  getEventPosition: (e) =>
    # container dimensions
    wCont = parseFloat(@markersContainer.width())
    hCont = parseFloat(@markersContainer.height())
    # if(
    #   @markersContainer.css('backgroundImage') &&
    #   @markersContainer.css('backgroundImage') != 'none'
    # )
    if @image
      # if there is an image, we need to calculate with image in mind
      xPx = e.pageX - @container.offset().left
      yPx = e.pageY - @container.offset().top
      wImg = @image.width()
      hImg = @image.height()
      xImg = parseInt(@image.css('left'))
      yImg = parseInt(@image.css('top'))
      xPc = ((xPx + Math.abs(xImg)) / wImg) * 100
      yPc = ((yPx + Math.abs(yImg)) / hImg) * 100
    else
      # or we can just look at the container
      xPc = (e.pageX - @container.offset().left) / wCont
      yPc =  (e.pageY - @container.offset().top) / hCont
    [xPc, yPc]

  # ------------------------------------------ Events

  mouseup: (e) =>
    # dealing with markers, esp. dragging markers
    marker = @markersContainer.find(".#{Planit.draggingClass}").first()
    if @draggingMarker().length > 0
      m = new Planit.Marker(@container, marker.attr('data-marker'))
      @options.markerDragEnd(e, m)
      m.savePosition()
      m.positionInfobox()
      @draggingMarker().removeClass(Planit.draggingClass)
    # if click is on the container
    if $(e.target).hasClass(Planit.markerContainerClass)
      @options.canvasClick(e, @getEventPosition(e))
    # if click is on the markers
    if(
      $(e.target).hasClass(Planit.markerClass) ||
      $(e.target).parents(".#{Planit.markerClass}").length > 0
    )
      if $(e.target).hasClass(Planit.markerClass)
        marker = $(e.target)
      else
        marker = $(e.target).parents(".#{Planit.markerClass}").first()
      m = new Planit.Marker(@container, marker.attr('data-marker'))
      @options.markerClick(e, m)
    true

  mousemove: (e) =>
    markers = @markersContainer.find(".#{Planit.markerClass}.#{Planit.draggingClass}")

    if markers.length > 0

      # only use first marker in case there are more than
      # one dragging
      #
      marker = markers.first()

      # we hide the infobox while dragging
      #
      if(
        Math.abs(e.pageX - marker.attr('data-drag-start-x')) > 0 ||
        Math.abs(e.pageY - marker.attr('data-drag-start-y')) > 0
      )
        @container.find("##{marker.attr('data-infobox')}").removeClass('active')

      # calculate positions
      #
      mouseLeft     = e.pageX - @container.offset().left
      mouseTop      = e.pageY - @container.offset().top
      planRight     = @container.width()
      planBottom    = @container.height()
      markerLeft    = mouseLeft - (marker.outerWidth() / 2)
      markerTop     = mouseTop - (marker.outerHeight() / 2)
      markerRight   = mouseLeft + (marker.outerWidth() / 2)
      markerBottom  = mouseTop + (marker.outerHeight() / 2)
      markerWidth   = marker.outerWidth()
      markerHeight  = marker.outerHeight()

      # find the left position of the marker based on
      # position of the mouse relative to the plan
      #
      if markerLeft <= 0
        markerX = 0
      else if markerRight < planRight
        markerX = markerLeft
      else
        markerX = planRight - markerWidth

      # find the left position of the marker based on
      # position of the mouse relative to the plan
      #
      if markerTop <= 0
        markerY = 0
      else if markerBottom < planBottom
        markerY = markerTop
      else
        markerY = planBottom - markerHeight

      # set the position of the marker
      #
      marker.css
        left: markerX
        top: markerY

  # ------------------------------------------ Event Callbacks

  markerDragEnd: (event, marker) =>
    if @options.markerDragEnd
      @options.markerDragEnd(event, marker)

  markerClick: (event, marker) =>
    if @options.markerClick
      @options.markerClick(event, marker)

  canvasClick: (event, coords) =>
    if @options.canvasClick
      @options.canvasClick(event, coords)