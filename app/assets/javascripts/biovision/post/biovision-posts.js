'use strict';

const BiovisionPosts = {
    loadPosts: function (e) {
        e.preventDefault();

        const button = this;
        const container = document.getElementById(button.getAttribute('data-container'));
        if (container) {
            const list = container.querySelector('div.list');

            if (list && !button.classList.contains('loading')) {
                const url = button.getAttribute('href');
                const request = Biovision.newAjaxRequest('get', url, function () {
                    button.classList.remove('loading');

                    const response = JSON.parse(this.responseText);
                    let nextLink;
                    if (response.hasOwnProperty('data')) {
                        response.data.forEach(function (element) {
                            if (element.hasOwnProperty('meta')) {
                                list.insertAdjacentHTML('beforeEnd', element.meta['html_preview']);
                            }
                        });
                    }
                    if (response.hasOwnProperty('links')) {
                        const links = response.links;
                        if (links.hasOwnProperty('next')) {
                            nextLink = links.next;
                        }
                    }
                    if (nextLink) {
                        button.setAttribute('href', nextLink);
                    } else {
                        button.classList.add('hidden');
                    }
                });

                button.classList.add('loading');
                request.send();
            }
        }
    }
};

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.posts-loader').forEach(function (button) {
        button.addEventListener('click', BiovisionPosts.loadPosts);
    });
});