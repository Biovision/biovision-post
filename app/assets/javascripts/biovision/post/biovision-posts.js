'use strict';

const Posts = {
    initialized: false,
    autoInit: true,
    components: {},
    init: function () {
        for (let component in this.components) {
            if (this.components.hasOwnProperty(component)) {
                if (this.components[component].hasOwnProperty('init')) {
                    this.components[component].init();
                }
            }
        }

        this.initialized = true;
    }
};

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

Posts.components.calendar = {
    initialized: false,
    element: undefined,
    dates: [],
    current: 0,
    buttons: {},
    header: undefined,
    days: undefined,
    init: function () {
        this.element = document.getElementById('posts-calendar');
        if (this.element) {
            const component = this;
            const url = this.element.getAttribute('data-url');
            const request = Biovision.newAjaxRequest('get', url, function () {
                const response = JSON.parse(this.responseText);
                if (response.hasOwnProperty('meta')) {
                    const meta = response['meta'];
                    if (meta.hasOwnProperty('dates')) {
                        meta.dates.forEach(function (years) {
                            const year = years['year'];
                            if (years.hasOwnProperty('months')) {
                                years['months'].forEach(function (months) {
                                    if (months['days']) {
                                        const days = {};
                                        months["days"].forEach(function (d) {
                                            days[d["day"]] = d["path"];
                                        });
                                        component.dates.push({
                                            "year": year,
                                            "month": months["month"],
                                            "text": months["name"] + ' ' + year,
                                            "days": days
                                        })
                                    }
                                });
                            }
                        });

                        component.select(component.dates.length - 1);
                    }
                }
            });
            request.send();

            this.buttons["prev"] = this.element.querySelector('button.prev');
            this.buttons["next"] = this.element.querySelector('button.next');
            this.buttons["prev"].addEventListener('click', this.buttonClick);
            this.buttons["next"].addEventListener('click', this.buttonClick);
            this.header = this.element.querySelector('.header span');
            this.days = this.element.querySelector('.days');

            this.initialized = true;
        }
    },
    select: function (number) {
        const component = Posts.components.calendar;
        if (number < 0 || number >= component.dates.length) {
            return;
        }
        component.current = number;
        if (number > 0) {
            component.buttons["prev"].setAttribute('data-number', number - 1);
            component.buttons["prev"].disabled = false;
        } else {
            component.buttons["prev"].disabled = true;
        }
        if (number < component.dates.length - 1) {
            component.buttons["next"].setAttribute('data-number', number + 1);
            component.buttons["next"].disabled = false;
        } else {
            component.buttons["next"].disabled = true;
        }
        const item = component.dates[number];

        /**
         * Month number starts from 0, so we use the next month and day 0
         * to get the last day of actual month
         *
         * @type {number}
         */
        const dayCount = new Date(item["year"], item["month"], 0).getDate();
        const dayNumber = new Date(item["year"], item["month"] - 1, 1).getDay();
        component.header.innerHTML = item["text"];
        component.days.innerHTML = "";
        let buffer = "";
        let style = "";
        for (let d = 1; d <= dayCount; d++) {
            if (d === 1 && dayNumber !== 1) {
                style = ' style="margin-left:calc(100% / 7 * ';
                style += (dayNumber > 0) ? (dayNumber - 1) : 6;
                style += ')"';
            } else {
                style = "";
            }
            buffer += '<div' + style + '><span>';
            if (item.days[d]) {
                buffer += '<a href="' + item.days[d] + '">' + d + '</a>';
            } else {
                buffer += d;
            }
            buffer += '</span></div>';
        }
        component.days.innerHTML = buffer;
    },
    buttonClick: function (event) {
        const button = event.target;
        const number = parseInt(button.getAttribute('data-number'));
        Posts.components.calendar.select(number);
    }
};

Biovision.components.posts = Posts;

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.posts-loader').forEach(function (button) {
        button.addEventListener('click', BiovisionPosts.loadPosts);
    });
});