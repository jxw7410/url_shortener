import React from 'react';
import ReactDom from 'react-dom';
import Root from './components/root';
import ReduxStore from './store/store';

document.addEventListener('DOMContentLoaded', () => {
    let store = ReduxStore();
    const root = document.getElementById('root');
    ReactDom.render(<Root store={store} />, root);
});

