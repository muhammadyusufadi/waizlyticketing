class App.Sidebar extends App.Controller
  elements:
    '.tabsSidebar-tab': 'tabs'
    '.sidebar':         'sidebars'

  events:
    'click .tabsSidebar-tab': 'toggleTab'
    'click .tabsSidebar-close': 'toggleSidebar'
    'click .sidebar-header .js-headline': 'toggleDropdown'

  constructor: ->
    super

    for item in @items
      item.parentSidebar = @

    @render()

    # get active tab by name
    if @name
      name = @name

    # get active tab last state
    if !name && @sidebarState
      name = @sidebarState.active

    # get active tab by first tab
    if !name
      name = @tabs.first().data('tab')

    # activate first tab
    @toggleTabAction(name)

  render: =>
    itemsLocal = []
    for item in @items
      itemLocal = item.sidebarItem()
      if itemLocal
        itemsLocal.push itemLocal

    # container
    localEl = $(App.view('generic/sidebar_tabs')(
      items:          itemsLocal
      scrollbarWidth: App.Utils.getScrollBarWidth()
      dir:            App.i18n.dir()
    ))

    # init sidebar badge
    for item in itemsLocal
      el = localEl.find('.tabsSidebar-tab[data-tab="' + item.name + '"]')
      if item.badgeCallback
        item.badgeCallback(el)
      else
        @badgeRender(el, item)

    # init sidebar content
    for item in itemsLocal
      if item.sidebarCallback
        el = localEl.filter('.sidebar[data-tab="' + item.name + '"]')
        item.sidebarCallback(el.find('.sidebar-content'))
        @sidebarActionsRender(item.name, item.sidebarActions, el.find('.js-actions'))

    @html(localEl)

  sidebarActionsRender: (name, sidebarActions, el = undefined) =>
    if !el
      el = @el.find('.sidebar[data-tab="' + name + '"] .js-actions')

    @actionsRows ||= {}
    @actionsRows[name]?.releaseController()
    return if _.isEmpty(sidebarActions)

    @actionsRows[name] = new SidebarActionRow(
      el:    el
      items: sidebarActions
      type:  'small'
    )

  badgeRender: (el, item) =>
    @badgeEl = el
    @badgeRenderLocal(item)

  badgeRenderLocal: (item) =>
    @badgeEl.html(App.view('generic/sidebar_tabs_item')(icon: item.badgeIcon))

  toggleDropdown: (e) ->
    e.stopPropagation()
    $(e.currentTarget).next('.js-actions').find('.dropdown-toggle').dropdown('toggle')

  toggleSidebar: =>
    @el.parent().find('.tabsSidebar-sidebarSpacer').toggleClass('is-closed')
    @el.filter('.tabsSidebar').toggleClass('is-closed')
    #@el.parent().next('.attributeBar').toggleClass('is-closed')

  showSidebar: =>
    @el.parent().find('.tabsSidebar-sidebarSpacer').removeClass('is-closed')
    @el.filter('.tabsSidebar').removeClass('is-closed')
    #@el.parent().next('.attributeBar').addClass('is-closed')

  toggleTab: (e) =>

    # get selected tab
    name = $(e.target).closest('.tabsSidebar-tab').data('tab')
    if name

      # if current tab is selected again, toggle side bar
      if name is @currentTab
        @toggleSidebar()

      # toggle content tab
      else
        @toggleTabAction(name)

  toggleTabAction: (name) =>
    return if !name

    # remove active state
    @tabs.removeClass('active')

    if name == 'shared_draft'
      draft_enabled = _.find @items, (elem) -> elem?.item?.name == 'shared_draft' and elem.sidebarItem()?

      if !draft_enabled?
        name = 'template'

        available_sidebar = _.first @items, (elem) -> elem.sidebarItem()?
        available_sidebar?.shown = true

    # remember sidebarState for outsite
    if @sidebarState
      @sidebarState.active = name

    # add active state
    @$('.tabsSidebar-tab[data-tab=' + name + ']').addClass('active')

    # hide all content tabs
    @sidebars.addClass('hide')

    # show active tab content
    tabContent = @$('.sidebar[data-tab=' + name + ']')
    tabContent.removeClass('hide')

    # remember current tab
    @currentTab = name

    # get current sidebar controller
    for item in @items
      itemLocal = item.sidebarItem()
      if itemLocal && itemLocal.name && itemLocal.name is @currentTab && item.shown
        item.shown()

    # show sidebar if not shown
    @showSidebar()

class SidebarActionRow extends App.Controller
  constructor: ->
    super
    @render()

  render: ->
    @html App.view('generic/actions')(
      items: @items
      type:  @type
    )

    for item in @items
      do (item) =>
        @$('[data-type="' + item.name + '"]').off('click').on(
          'click'
          (e) ->
            e.preventDefault()
            item.callback()
        )
