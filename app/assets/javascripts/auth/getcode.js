const {data} = require('./data');

export default async (req, res) => {
    res.redirect(data.redirectUri);
}