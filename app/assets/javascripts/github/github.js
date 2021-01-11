// timer when user input search query
function delay(callback, ms) {
    var timer = 0;
    return function() {
        var context = this, args = arguments;
        clearTimeout(timer);
        timer = setTimeout(function () {
            callback.apply(context, args);
        }, 1000);
    };
}

// return promise
function get_user_repositories() {
    let user_id = $('#user_id').val()

    return axios.get('favorite-repositories/' + user_id).then( (response) => response.data)

}

// get all repositories when load the page
var current_user_favorite_repositories = get_user_repositories()

// use this global variable for change flag in pagination callback function
var from_search = false;
function set_searchable_flag(boolean = true) {
    from_search = boolean
}



// search repositories
$('#search_repositories').on('input', delay(function (e) {
    let value = this.value.trim()

    if (value) {
        let response = get_repositories(value)
        set_searchable_flag(true)
        response.then(function (response) {
            set_pagination(response.data.total_count)
        })
        append_repositories(response)
    } else {
        $('#repos_pagination').html('')
        $('#git_table_body').html('')
    }

}))

// set pagination
function set_pagination(total_count){
    $('#repos_pagination').pagination({
        dataSource: new Array(total_count),
        pageSize: 30,
        showPrevious: true,
        showNext: true,
        ulClassName: 'pagination',
        callback: function(data, pagination)  {
            if (!from_search){
                let page = pagination.pageNumber
                let value = $('#search_repositories').val()
                let response = get_repositories(value, page)
                append_repositories(response)
                set_searchable_flag(false)
            }
        }
    })

    set_searchable_flag(false)

}


// get repositories (request)
function get_repositories(value, page = 1) {
    console.log('get_repositories');
    $('#repos_pagination').css('display', 'none')

    const promise = axios.get('git-search', {
        params: {
            q: value,
            page : page
        }
    })

    return promise.then((response) => response)
}

// append html to git table
function append_repositories(response) {
    let table_body = $('#git_table_body')
    table_body.html('')

    response.then(function (response) {
        $.each( response.data.repositories[2][1], function (index, value) {

            // check any repo id in current user ids
            let checked = ''
            current_user_favorite_repositories.then(function (data) {
                    if (data.includes(value[0][1])){
                        checked = 'checked="checked"'
                    }
            }).then(function () {
                let row = '<tr>'
                    + '<td><input type="checkbox" value="' + value[0][1] + '" id="is_favorite_repository" ' + checked +' /></td>'
                    + '<td>' + value[0][1] + '</td>'
                    + '<td>' + value[3][1] + '</td>'
                    + '<td><a href="' + value[6][1] + '" target="_blank">' + value[6][1] + '</a></td>'
                    + '<td>' + value[7][1] + '</td>'
                '</tr>'

                table_body.append(row)
            })
        })

        $('#repos_pagination').css('display', 'block')


    })

}


// add or remove favorite repositories
$(document).on('change', '#is_favorite_repository' , function(){
    let ischecked= $(this).is(':checked');
    let user_id = $('#user_id').val()

    if(ischecked){
        axios.post('add-favorite-repository', {
            repository_id: $(this).val(),
            user_id: user_id,
            authenticity_token: $('[name="csrf-token"]')[0].content
        })

    }else{
        axios.post('remove-favorite-repository', {
            repository_id: $(this).val(),
            user_id: user_id,
            authenticity_token: $('[name="csrf-token"]')[0].content
        })
    }
})



