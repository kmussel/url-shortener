import React from 'react';
import ReactDOM from 'react-dom';

import { shallow, configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

// import 'react-dates/initialize';
import Shortener from 'shortener';

test('rendered component', () => {
  const wrapper = shallow(<Shortener />);
  expect(wrapper.find('input')).toExist();

  expect(wrapper).toHaveState({
    source: '',
    loading: false,
    error: null,
    success: null
  })
});



it('Posts data to server and returns a successful response', done => { // 1
  const mockSuccessResponse = {key: "abcde"};
  const mockJsonPromise = Promise.resolve(mockSuccessResponse); // 2
  const mockFetchPromise = Promise.resolve({ // 3
    ok: true,
    json: () => mockJsonPromise,
  });
  global.fetch = jest.fn().mockImplementation(() => mockFetchPromise); // 4

  const wrapper = shallow(<Shortener />); // 5

  
  let source = 'http://google.com'
  wrapper.setState({ source: source });

  wrapper.find('form').simulate('submit', { preventDefault () {} });

  expect(global.fetch).toHaveBeenCalledTimes(1);
  expect(global.fetch).toHaveBeenCalledWith("/api/v1/short_urls", {"body": "{\"shorturl\":{\"source\":\""+ source + "\"}}", "cache": "no-cache", "credentials": "same-origin", "headers": {"Content-Type": "application/json"}, "method": "POST", "redirect": "follow", "referrerPolicy": "no-referrer"});

  process.nextTick(() => { // 6
    expect(wrapper.state()).toEqual({
      "loading": false,
      "error": null,
      "source": source,
      "success": mockSuccessResponse
    });

    global.fetch.mockClear(); // 7
    done(); // 8
  });
});
