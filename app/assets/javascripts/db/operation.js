const {tokenSchema} = require('./schema');
const Token = tokenSchema;

exports.findToken = async (userId) => {
    const res = await Token.find({userId: userId});
    return res;
};

exports.saveToken = async (userId, accessToken, refreshToken) => {
    await Token.updateOne(
        {userId: userId},
        {userId: userId, accessToken: accessToken, refreshToken: refreshToken},
        {upsert: true}
    );
};

exports.deleteToken = async (userId) => {
    await Token.remove({userId: `${userId}`}, function (err) {
        if (err) throw err;
    });
};